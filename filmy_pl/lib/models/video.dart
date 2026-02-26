class Video {
  final String id;
  final String filename;
  final String name;
  final String description;
  final String url;
  final String? thumbnail;

  Video({
    required this.id,
    required this.filename,
    required this.name,
    required this.description,
    required this.url,
    this.thumbnail,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      filename: json['filename'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'],
    );
  }

  String get displayName {
    return name
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();
  }
}
