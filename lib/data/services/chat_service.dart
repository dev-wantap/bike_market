import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat.dart';

class ChatService {
  static final _supabase = Supabase.instance.client;

  /// 채팅방 조회 또는 생성
  static Future<ChatRoom> getOrCreateChatRoom(String productId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final intProductId = int.tryParse(productId);
      if (intProductId == null) {
        throw Exception('유효하지 않은 상품 ID입니다.');
      }

      // 기존 채팅방 확인
      final existingRoom = await _supabase
          .from('chat_rooms')
          .select('''
            id, product_id, buyer_id, created_at,
            buyer:profiles!chat_rooms_buyer_id_fkey(
              id, nickname, profile_image_url, location
            ),
            products!inner(
              id, title, price, description, image_urls, category, location,
              status, view_count, created_at, updated_at, seller_id,
              profiles!products_seller_id_fkey(
                id, nickname, profile_image_url, location
              )
            )
          ''')
          .eq('product_id', intProductId)
          .eq('buyer_id', user.id)
          .maybeSingle();

      if (existingRoom != null) {
        return ChatRoom.fromJson(existingRoom, user.id);
      }

      // 새 채팅방 생성
      final newRoom = await _supabase
          .from('chat_rooms')
          .insert({'product_id': intProductId, 'buyer_id': user.id})
          .select('''
            id, product_id, buyer_id, created_at,
            buyer:profiles!chat_rooms_buyer_id_fkey(
              id, nickname, profile_image_url, location
            ),
            products!inner(
              id, title, price, description, image_urls, category, location,
              status, view_count, created_at, updated_at, seller_id,
              profiles!products_seller_id_fkey(
                id, nickname, profile_image_url, location
              )
            )
          ''')
          .single();

      log('Created new chat room: ${newRoom['id']}');
      return ChatRoom.fromJson(newRoom, user.id);
    } catch (e) {
      log('Error getting or creating chat room: $e');
      throw Exception('채팅방을 만들 수 없습니다.');
    }
  }

  /// 현재 사용자의 채팅방 목록 조회
  static Future<List<ChatRoom>> getChatRooms() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 구매자인 채팅방 (마지막 메시지 포함)
      final buyerResponse = await _supabase.rpc(
        'get_chat_rooms_with_last_message',
        params: {'user_id': user.id, 'as_buyer': true},
      );

      // 판매자인 채팅방 (마지막 메시지 포함)
      final sellerResponse = await _supabase.rpc(
        'get_chat_rooms_with_last_message',
        params: {'user_id': user.id, 'as_buyer': false},
      );

      // 두 결과를 합치고 중복 제거
      final allRooms = <Map<String, dynamic>>[];

      // RPC 함수 반환값을 Map으로 변환
      final buyerRooms = (buyerResponse as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      final sellerRooms = (sellerResponse as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();

      allRooms.addAll(buyerRooms);
      allRooms.addAll(sellerRooms);

      // ID로 중복 제거
      final uniqueRooms = <int, Map<String, dynamic>>{};
      for (final room in allRooms) {
        uniqueRooms[room['id'] as int] = room;
      }

      // 시간순 정렬
      final sortedRooms = uniqueRooms.values.toList()
        ..sort(
          (a, b) => DateTime.parse(
            b['created_at'],
          ).compareTo(DateTime.parse(a['created_at'])),
        );

      return sortedRooms
          .map((json) => ChatRoom.fromJson(json, user.id))
          .toList();
    } catch (e) {
      log('Error fetching chat rooms: $e');
      return [];
    }
  }

  /// 메시지 전송
  static Future<Message> sendMessage(int roomId, String content) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await _supabase
          .from('chat_messages')
          .insert({
            'room_id': roomId,
            'sender_id': user.id,
            'content': content,
            'is_read': false,
          })
          .select()
          .single();

      log('Message sent: ${response['id']}');
      return Message.fromJson(response, user.id);
    } catch (e) {
      log('Error sending message: $e');
      throw Exception('메시지를 보낼 수 없습니다.');
    }
  }

  /// 특정 채팅방의 메시지 스트림 (실시간)
  static Stream<List<Message>> getMessagesStream(int roomId) {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return Stream.error('로그인이 필요합니다.');
    }

    return _supabase
        .from('chat_messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .asStream()
        .map(
          (data) => (data as List)
              .map((json) => Message.fromJson(json, user.id))
              .toList(),
        );
  }

  /// 채팅방의 기존 메시지 조회 (페이지네이션)
  static Future<List<Message>> getMessages(
    int roomId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await _supabase
          .from('chat_messages')
          .select()
          .eq('room_id', roomId)
          .order('created_at', ascending: false)
          .limit(limit)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => Message.fromJson(json, user.id))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      log('Error fetching messages: $e');
      return [];
    }
  }

  /// 메시지 읽음 처리
  static Future<void> markMessagesAsRead(int roomId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      await _supabase
          .from('chat_messages')
          .update({'is_read': true})
          .eq('room_id', roomId)
          .neq('sender_id', user.id) // 자신이 보낸 메시지는 제외
          .eq('is_read', false);

      log('Messages marked as read for room: $roomId');
    } catch (e) {
      log('Error marking messages as read: $e');
    }
  }

  /// 채팅방의 읽지 않은 메시지 개수 조회
  static Future<int> getUnreadMessageCount(int roomId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 0;
      }

      final response = await _supabase
          .from('chat_messages')
          .select()
          .eq('room_id', roomId)
          .neq('sender_id', user.id) // 자신이 보낸 메시지는 제외
          .eq('is_read', false)
          .count();

      return response.count;
    } catch (e) {
      log('Error getting unread message count: $e');
      return 0;
    }
  }

  /// 현재 사용자의 모든 채팅방에서 읽지 않은 메시지 총 개수 조회
  static Future<int> getTotalUnreadCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 0;
      }

      // 현재 사용자의 모든 채팅방 조회
      final chatRooms = await getChatRooms();

      int totalUnread = 0;
      for (final chatRoom in chatRooms) {
        final count = await getUnreadMessageCount(chatRoom.id);
        totalUnread += count;
      }

      return totalUnread;
    } catch (e) {
      log('Error getting total unread count: $e');
      return 0;
    }
  }

  /// 전체 읽지 않은 메시지 수 실시간 스트림
  static Stream<int> getTotalUnreadCountStream() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    // 실시간으로 메시지 변경을 감지하고 전체 읽지 않은 메시지 수를 계산
    return _supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .map((data) async {
          try {
            return await getTotalUnreadCount();
          } catch (e) {
            log('Error in total unread count stream: $e');
            return 0;
          }
        })
        .asyncMap((future) => future);
  }

  /// 실시간 메시지 구독 (Supabase Realtime)
  static RealtimeChannel subscribeToMessages(
    int roomId,
    void Function(Message message) onMessage,
  ) {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final channel = _supabase
        .channel('chat_messages:room_id=eq.$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            try {
              final messageData = payload.newRecord;
              final message = Message.fromJson(messageData, user.id);
              onMessage(message);
              log('Real-time message received: ${message.id}');
            } catch (e) {
              log('Error processing real-time message: $e');
            }
          },
        )
        .subscribe();

    return channel;
  }

  /// 실시간 구독 해제
  static Future<void> unsubscribe(RealtimeChannel channel) async {
    try {
      await _supabase.removeChannel(channel);
      log('Unsubscribed from real-time messages');
    } catch (e) {
      log('Error unsubscribing: $e');
    }
  }
}
