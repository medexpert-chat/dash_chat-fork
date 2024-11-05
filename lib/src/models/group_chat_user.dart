part of dash_chat_2;

class GroupChatUser {
  int id;
  String? fullName;
  String? avatarUrl;
  String? role;
  String? label;
  final DateTime? lastOnlineAt;

  GroupChatUser({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.label,
    this.lastOnlineAt,
  });

  factory GroupChatUser.fromJson(Map<String, dynamic> json) {
    return GroupChatUser(
      id: json['id'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'] ?? '',
      label: json['label'] ?? '',
      lastOnlineAt: DateTime.tryParse(json['last_online_at'] ?? ''),
    );
  }
}
