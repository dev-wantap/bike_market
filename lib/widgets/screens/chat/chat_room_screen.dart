import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/models/chat.dart';
import '../../../data/services/chat_service.dart';
import '../../common/chat_bubble.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatRoomScreen({
    super.key,
    required this.chatRoom,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _disposeRealtimeSubscription();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      // 기존 메시지 로드
      final messages = await ChatService.getMessages(widget.chatRoom.id);

      // 실시간 구독 설정
      _setupRealtimeSubscription();

      // 메시지 읽음 처리
      await ChatService.markMessagesAsRead(widget.chatRoom.id);

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });

        // 스크롤을 맨 아래로
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      log('Error initializing chat: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setupRealtimeSubscription() {
    try {
      _realtimeChannel = ChatService.subscribeToMessages(
        widget.chatRoom.id,
        (message) {
          if (mounted) {
            setState(() {
              _messages.add(message);
            });
            _scrollToBottom();

            // 상대방 메시지인 경우 읽음 처리
            if (!message.isMe) {
              ChatService.markMessagesAsRead(widget.chatRoom.id);
            }
          }
        },
      );
    } catch (e) {
      log('Error setting up realtime subscription: $e');
    }
  }

  Future<void> _disposeRealtimeSubscription() async {
    if (_realtimeChannel != null) {
      await ChatService.unsubscribe(_realtimeChannel!);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  widget.chatRoom.otherUser.nickname[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSmall),
              Text(widget.chatRoom.otherUser.nickname, style: AppTextStyles.subtitle1),
            ],
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                widget.chatRoom.otherUser.nickname[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSmall),
            Text(widget.chatRoom.otherUser.nickname, style: AppTextStyles.subtitle1),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Handle menu
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProductInfoBar(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMedium,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildProductInfoBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            clipBehavior: Clip.hardEdge,
            child: widget.chatRoom.product.images.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.chatRoom.product.images.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.border,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.border,
                      child: const Icon(
                        Icons.pedal_bike,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.border,
                    child: const Icon(
                      Icons.pedal_bike,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
          ),
          const SizedBox(width: AppDimensions.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatRoom.product.title,
                  style: AppTextStyles.subtitle2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingXSmall),
                Text(
                  _formatPrice(widget.chatRoom.product.price),
                  style: AppTextStyles.price,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('상품보기'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.paddingMedium,
        right: AppDimensions.paddingMedium,
        top: AppDimensions.paddingMedium,
        bottom:
            AppDimensions.paddingMedium + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // Handle attachment
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('파일 첨부 기능')));
            },
            icon: const Icon(Icons.add),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                fillColor: AppColors.surface,
                filled: true,
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSmall),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isSending ? null : _sendMessage,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSending = true;
    });

    try {
      await ChatService.sendMessage(widget.chatRoom.id, content);
      log('Message sent successfully');
    } catch (e) {
      log('Error sending message: $e');
      if (mounted) {
        // 에러 발생 시 메시지 내용 복원
        _messageController.text = content;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('메시지 전송에 실패했습니다: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }
}
