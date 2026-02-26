class Comment {
  final int id;
  final String email;
  final String content;
  final String createdAt;

  Comment({
    required this.id,
    required this.email,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  String get shortEmail {
    final parts = email.split('@');
    if (parts.isEmpty) return email;
    final name = parts[0];
    if (name.length <= 3) return '${name}***';
    return '${name.substring(0, 3)}***';
  }
}
