class GroupChat {
  final int id;
  final String name;
  final String? photoUrl;
  final int adminId;
  final String latestMessage;
  final String latestMessageTime;

  GroupChat({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.adminId,
    required this.latestMessage,
    required this.latestMessageTime,
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed Group',
      photoUrl: json['photo_url'],
      adminId: json['admin_id'] ?? 0,
      latestMessage: json['latest_message'] ?? '',
      latestMessageTime: json['latest_message_time'] ?? '',
    );
  }
}
