import 'user.dart';

/// Model for a like on a post.
class Like {
  final String id;
  final String postId;
  final User user;
  final DateTime createdAt;

  const Like({
    required this.id,
    required this.postId,
    required this.user,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'] as String,
      postId: json['postId'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'user': user.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };
}
