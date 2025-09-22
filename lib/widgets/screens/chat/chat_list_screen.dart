import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/chat.dart';
import '../../../data/services/chat_service.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ChatRoom> _chatRooms = [];
  Map<int, int> _unreadCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
  }

  Future<void> _fetchChatRooms() async {
    try {
      final chatRooms = await ChatService.getChatRooms();

      // 각 채팅방의 읽지 않은 메시지 개수 조회
      final unreadCounts = <int, int>{};
      for (final chatRoom in chatRooms) {
        final count = await ChatService.getUnreadMessageCount(chatRoom.id);
        unreadCounts[chatRoom.id] = count;
      }

      if (mounted) {
        setState(() {
          _chatRooms = chatRooms;
          _unreadCounts = unreadCounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching chat rooms: $e');
      if (mounted) {
        setState(() {
          _chatRooms = [];
          _unreadCounts = {};
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('채팅'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchChatRooms,
        child: _chatRooms.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                itemCount: _chatRooms.length,
                itemBuilder: (context, index) {
                  final chatRoom = _chatRooms[index];
                  return _buildChatTile(context, chatRoom);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.textLight,
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text(
              '아직 채팅 중인 거래가 없습니다',
              style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              '관심있는 상품에서 채팅을 시작해보세요',
              style: AppTextStyles.body2.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatRoom chatRoom) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      leading: Stack(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: const Icon(
              Icons.pedal_bike,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  chatRoom.otherUser.nickname[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chatRoom.otherUser.nickname,
              style: AppTextStyles.subtitle1,
            ),
          ),
          if ((_unreadCounts[chatRoom.id] ?? 0) > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
                vertical: 2,
              ),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  '${_unreadCounts[chatRoom.id] ?? 0}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.spacingXSmall),
          Text(
            chatRoom.product.title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacingXSmall),
          Row(
            children: [
              Expanded(
                child: Text(
                  chatRoom.lastMessage,
                  style: AppTextStyles.body2.copyWith(
                    color: (_unreadCounts[chatRoom.id] ?? 0) > 0
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: (_unreadCounts[chatRoom.id] ?? 0) > 0
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatTime(chatRoom.lastMessageTime),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              chatRoom: chatRoom,
            ),
          ),
        ).then((_) {
          // 채팅방에서 돌아왔을 때 목록 새로고침
          _fetchChatRooms();
        });
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today - show time only
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return '어제';
    } else {
      // Other days - show date
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
