import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/services/chat_service.dart';

class ChatNotificationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 채팅방별 안 읽은 메시지 개수
  final Map<String, int> _unreadCounts = {};

  // 실시간 구독 관리
  RealtimeChannel? _subscription;
  bool _isInitialized = false;
  bool _hasGlobalUnread = false;

  // Getters
  Map<String, int> get unreadCounts => Map.unmodifiable(_unreadCounts);

  /// 전체 안 읽은 메시지 개수
  int get totalUnreadCount {
    return _unreadCounts.values.fold(0, (sum, count) => sum + count);
  }

  /// 특정 채팅방의 안 읽은 메시지 개수
  int unreadCountFor(String chatRoomId) {
    return _unreadCounts[chatRoomId] ?? 0;
  }

  /// 글로벌 배지 표시 여부 (하단 네비게이션용)
  bool get hasGlobalUnread => _hasGlobalUnread;

  /// 초기화 - 앱 시작 시 호출
  Future<void> initialize() async {
    if (_isInitialized) {
      log('ChatNotificationProvider already initialized');
      return;
    }

    final user = _supabase.auth.currentUser;
    if (user == null) {
      log('No authenticated user, skipping initialization');
      return;
    }

    try {
      log('Initializing ChatNotificationProvider for user: ${user.id}');

      // 1. 초기 안 읽은 메시지 개수 로드
      await _loadInitialUnreadCounts();

      // 2. 실시간 구독 시작
      await _subscribeToRealtimeMessages();

      _isInitialized = true;
      _hasGlobalUnread = totalUnreadCount > 0;

      log('ChatNotificationProvider initialized successfully');
      log('Initial unread counts: $_unreadCounts');
      log('Total unread: $totalUnreadCount');
    } catch (e) {
      log('Error initializing ChatNotificationProvider: $e');
    }
  }

  /// 초기 안 읽은 메시지 개수 로드
  Future<void> _loadInitialUnreadCounts() async {
    try {
      // 사용자가 참여한 모든 채팅방 조회
      final chatRooms = await ChatService.getChatRooms();

      _unreadCounts.clear();

      // 각 채팅방의 안 읽은 메시지 개수 조회
      for (final chatRoom in chatRooms) {
        final count = await ChatService.getUnreadMessageCount(chatRoom.id);
        if (count > 0) {
          _unreadCounts[chatRoom.id.toString()] = count;
        }
      }

      log('Loaded initial unread counts: $_unreadCounts');
    } catch (e) {
      log('Error loading initial unread counts: $e');
    }
  }

  /// 실시간 메시지 구독
  Future<void> _subscribeToRealtimeMessages() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 기존 구독이 있다면 해제
      await _unsubscribe();

      // 새로운 구독 생성
      _subscription = _supabase.channel('chat_notifications_${user.id}');

      // chat_messages 테이블의 INSERT 이벤트 구독
      _subscription!
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'chat_messages',
            callback: _handleRealtimeMessage,
          )
          .subscribe();

      log('Subscribed to realtime chat messages for user: ${user.id}');
    } catch (e) {
      log('Error subscribing to realtime messages: $e');
    }
  }

  /// 실시간 메시지 처리
  void _handleRealtimeMessage(PostgresChangePayload payload) async {
    try {
      final messageData = payload.newRecord;
      final senderId = messageData['sender_id'] as String?;
      final roomId = messageData['room_id']?.toString();
      final content = messageData['content'] as String?;

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null || roomId == null) return;

      // 내가 보낸 메시지는 알림 처리하지 않음
      if (senderId == currentUser.id) {
        log('Ignoring message from self: $senderId');
        return;
      }

      // 해당 채팅방이 내가 참여한 채팅방인지 확인
      final isParticipant = await _isParticipantInChatRoom(int.parse(roomId));
      if (!isParticipant) {
        log('User is not participant in chat room: $roomId');
        return;
      }

      log('New message received in room $roomId from $senderId: $content');

      // 안 읽은 메시지 개수 증가
      _unreadCounts[roomId] = (_unreadCounts[roomId] ?? 0) + 1;
      _hasGlobalUnread = true;

      log('Updated unread count for room $roomId: ${_unreadCounts[roomId]}');
      log('Total unread count: $totalUnreadCount');

      // UI 업데이트 알림
      notifyListeners();
    } catch (e) {
      log('Error handling realtime message: $e');
    }
  }

  /// 사용자가 특정 채팅방의 참여자인지 확인
  Future<bool> _isParticipantInChatRoom(int roomId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('chat_rooms')
          .select('buyer_id, products!inner(seller_id)')
          .eq('id', roomId)
          .single();

      final buyerId = response['buyer_id'] as String?;
      final products = response['products'] as Map<String, dynamic>?;
      final sellerId = products?['seller_id'] as String?;

      // 구매자이거나 판매자인 경우 참여자
      return buyerId == user.id || sellerId == user.id;
    } catch (e) {
      log('Error checking chat room participant: $e');
      return false;
    }
  }

  /// 특정 채팅방을 읽음 처리
  Future<void> markChatRoomAsRead(String chatRoomId) async {
    try {
      final roomId = int.tryParse(chatRoomId);
      if (roomId == null) {
        log('Invalid chat room ID: $chatRoomId');
        return;
      }

      // 서버에서 읽음 처리
      await ChatService.markMessagesAsRead(roomId);

      // 로컬 상태 업데이트
      final previousCount = _unreadCounts[chatRoomId] ?? 0;
      _unreadCounts.remove(chatRoomId);

      // 전체 안 읽은 메시지가 있는지 확인
      _hasGlobalUnread = totalUnreadCount > 0;

      log('Marked chat room $chatRoomId as read (was $previousCount unread)');
      log('Total unread count after marking as read: $totalUnreadCount');

      // UI 업데이트 알림
      notifyListeners();
    } catch (e) {
      log('Error marking chat room as read: $e');
    }
  }

  /// 모든 채팅방을 읽음 처리 (채팅 목록 화면 진입 시)
  void markAllAsRead() {
    if (_hasGlobalUnread) {
      _hasGlobalUnread = false;
      log('Marked all chat notifications as read for navigation badge');

      // UI 업데이트 알림 (하단 네비게이션 배지 제거용)
      notifyListeners();
    }
  }

  /// 특정 채팅방의 안 읽은 개수 수동 동기화
  Future<void> syncUnreadCount(String chatRoomId) async {
    try {
      final roomId = int.tryParse(chatRoomId);
      if (roomId == null) return;

      final count = await ChatService.getUnreadMessageCount(roomId);

      if (count > 0) {
        _unreadCounts[chatRoomId] = count;
      } else {
        _unreadCounts.remove(chatRoomId);
      }

      _hasGlobalUnread = totalUnreadCount > 0;

      log('Synced unread count for room $chatRoomId: $count');
      notifyListeners();
    } catch (e) {
      log('Error syncing unread count: $e');
    }
  }

  /// 모든 안 읽은 개수 새로고침
  Future<void> refreshAllUnreadCounts() async {
    try {
      await _loadInitialUnreadCounts();
      _hasGlobalUnread = totalUnreadCount > 0;

      log('Refreshed all unread counts: $_unreadCounts');
      notifyListeners();
    } catch (e) {
      log('Error refreshing all unread counts: $e');
    }
  }

  /// 구독 해제
  Future<void> _unsubscribe() async {
    if (_subscription != null) {
      try {
        await _subscription!.unsubscribe();
        log('Unsubscribed from realtime chat messages');
      } catch (e) {
        log('Error unsubscribing: $e');
      } finally {
        _subscription = null;
      }
    }
  }

  /// Provider 정리 (앱 종료 시 또는 로그아웃 시)
  void clear() {
    _unreadCounts.clear();
    _hasGlobalUnread = false;
    _isInitialized = false;
    notifyListeners();
    log('ChatNotificationProvider cleared');
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}
