import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/text_styles.dart';
import '../../data/models/chat.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.chatBubbleMaxWidth,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: AppDimensions.marginXSmall,
          horizontal: AppDimensions.marginMedium,
        ),
        child: Column(
          crossAxisAlignment: message.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: message.isMe
                    ? AppColors.chatBubbleMe
                    : AppColors.chatBubbleOther,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(
                    AppDimensions.chatBubbleRadius,
                  ),
                  topRight: const Radius.circular(
                    AppDimensions.chatBubbleRadius,
                  ),
                  bottomLeft: message.isMe
                      ? const Radius.circular(AppDimensions.chatBubbleRadius)
                      : const Radius.circular(AppDimensions.radiusSmall),
                  bottomRight: message.isMe
                      ? const Radius.circular(AppDimensions.radiusSmall)
                      : const Radius.circular(AppDimensions.chatBubbleRadius),
                ),
              ),
              child: _buildMessageContent(),
            ),
            const SizedBox(height: AppDimensions.spacingXSmall),
            Text(_formatTime(message.timestamp), style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: AppTextStyles.body2.copyWith(
            color: message.isMe ? Colors.white : AppColors.textPrimary,
          ),
        );
      case MessageType.image:
        return Column(
          children: [
            Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: const Icon(
                Icons.image,
                color: AppColors.textSecondary,
                size: AppDimensions.iconLarge,
              ),
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingSmall),
              Text(
                message.content,
                style: AppTextStyles.body2.copyWith(
                  color: message.isMe ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ],
        );
      case MessageType.system:
        return Text(
          message.content,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        );
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today - show time only
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Other days - show date and time
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
