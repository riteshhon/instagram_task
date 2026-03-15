import 'user.dart';

/// Model for a comment on a post (supports likes and nested replies).
class Comment {
  final String id;
  final String postId;
  final User user;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final List<Comment>? replies;

  const Comment({
    required this.id,
    required this.postId,
    required this.user,
    required this.text,
    required this.createdAt,
    this.likesCount = 0,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      text: json['text'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'user': user.toJson(),
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'likesCount': likesCount,
        'replies': replies?.map((e) => e.toJson()).toList(),
      };
}
