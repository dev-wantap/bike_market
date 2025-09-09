import 'product.dart';

enum MessageType { text, image, system }

class ChatRoom {
  final String id;
  final Product product;
  final Seller otherUser;
  final List<Message> messages;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.product,
    required this.otherUser,
    required this.messages,
    required this.unreadCount,
  });

  ChatRoom copyWith({
    String? id,
    Product? product,
    Seller? otherUser,
    List<Message>? messages,
    int? unreadCount,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      product: product ?? this.product,
      otherUser: otherUser ?? this.otherUser,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  String get lastMessage {
    if (messages.isEmpty) return '';
    return messages.last.content;
  }

  DateTime get lastMessageTime {
    if (messages.isEmpty) return DateTime.now();
    return messages.last.timestamp;
  }
}

class Message {
  final String id;
  final String content;
  final bool isMe;
  final DateTime timestamp;
  final MessageType type;

  const Message({
    required this.id,
    required this.content,
    required this.isMe,
    required this.timestamp,
    required this.type,
  });

  Message copyWith({
    String? id,
    String? content,
    bool? isMe,
    DateTime? timestamp,
    MessageType? type,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isMe: isMe ?? this.isMe,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}
