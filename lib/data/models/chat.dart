import 'product.dart';

enum MessageType { text, image, system }

class ChatRoom {
  final int id;
  final Product product;
  final Seller otherUser;
  final List<Message> messages;
  final int unreadCount;
  final DateTime createdAt;

  const ChatRoom({
    required this.id,
    required this.product,
    required this.otherUser,
    required this.messages,
    required this.unreadCount,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json, [String? currentUserId]) {
    final productData = json['products'] as Map<String, dynamic>;
    final product = Product.fromJson(productData);
    final buyerId = json['buyer_id'] as String;

    // 현재 사용자가 구매자면 판매자가 상대방, 판매자면 구매자가 상대방
    Seller otherUser;
    if (currentUserId != null && currentUserId == buyerId) {
      // 현재 사용자가 구매자 -> 판매자가 상대방
      otherUser = product.seller;
    } else {
      // 현재 사용자가 판매자 -> 구매자가 상대방
      final buyerData = json['buyer'] as Map<String, dynamic>;
      otherUser = Seller(
        id: buyerData['id'] as String,
        nickname: buyerData['nickname'] as String,
        profileImage: buyerData['profile_image_url'] as String? ?? '',
        location: buyerData['location'] as String? ?? '',
        otherProducts: [], // 빈 리스트로 초기화
      );
    }

    return ChatRoom(
      id: json['id'] as int,
      product: product,
      otherUser: otherUser,
      messages: [], // 메시지는 별도로 로드
      unreadCount: 0, // 별도로 계산
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  ChatRoom copyWith({
    int? id,
    Product? product,
    Seller? otherUser,
    List<Message>? messages,
    int? unreadCount,
    DateTime? createdAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      product: product ?? this.product,
      otherUser: otherUser ?? this.otherUser,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get lastMessage {
    if (messages.isEmpty) return '대화를 시작해보세요!';
    return messages.last.content;
  }

  DateTime get lastMessageTime {
    if (messages.isEmpty) return createdAt;
    return messages.last.timestamp;
  }
}

class Message {
  final int id;
  final int roomId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime timestamp;
  final MessageType type;
  final bool isMe;

  const Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.timestamp,
    required this.type,
    required this.isMe,
  });

  factory Message.fromJson(Map<String, dynamic> json, String currentUserId) {
    return Message(
      id: json['id'] as int,
      roomId: json['room_id'] as int,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      timestamp: DateTime.parse(json['created_at']),
      type: MessageType.text, // 현재는 텍스트만 지원
      isMe: json['sender_id'] == currentUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
      'is_read': isRead,
      'created_at': timestamp.toIso8601String(),
    };
  }

  Message copyWith({
    int? id,
    int? roomId,
    String? senderId,
    String? content,
    bool? isRead,
    DateTime? timestamp,
    MessageType? type,
    bool? isMe,
  }) {
    return Message(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isMe: isMe ?? this.isMe,
    );
  }
}
