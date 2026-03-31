class ChatUser {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final String? photoUrl;

  ChatUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.photoUrl,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? 'Unknown',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      photoUrl: json['image_url'],
    );
  }
}

class ChatSession {
  final int sessionId;
  final ChatUser otherUser;
  final String latestMessage;
  final String latestMessageTime;
  final int unreadCount;

  ChatSession({
    required this.sessionId,
    required this.otherUser,
    required this.latestMessage,
    required this.latestMessageTime,
    required this.unreadCount,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['session_id'] ?? 0,
      otherUser: ChatUser.fromJson(json['other_user'] ?? {}),
      latestMessage: json['latest_message'] ?? '',
      latestMessageTime: json['latest_message_time'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class ChatMessage {
  final int id;
  final int senderId;
  final String senderName;
  final String? senderEmail;
  final String content;
  final String createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderEmail,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      senderName: json['sender_name'] ?? 'Unknown',
      senderEmail: json['sender_email'],
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
      isRead: json['is_read'] ?? false,
    );
  }
}
