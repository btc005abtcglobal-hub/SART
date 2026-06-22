class CommunityPostModel {
  final String id;
  final String authorName;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int commentsCount;

  const CommunityPostModel({
    required this.id,
    required this.authorName,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.commentsCount,
  });

  CommunityPostModel copyWith({
    String? id,
    String? authorName,
    String? content,
    DateTime? timestamp,
    int? likes,
    int? commentsCount,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'commentsCount': commentsCount,
    };
  }

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      likes: json['likes'] as int,
      commentsCount: json['commentsCount'] as int,
    );
  }
}
