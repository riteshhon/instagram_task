import 'user.dart';

/// Model for a story (separate from posts feed).
class Story {
  final String id;
  final User user;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime createdAt;
  final bool isViewed;

  const Story({
    required this.id,
    required this.user,
    this.imageUrl,
    this.videoUrl,
    required this.createdAt,
    this.isViewed = false,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isViewed: json['isViewed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user.toJson(),
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'createdAt': createdAt.toIso8601String(),
        'isViewed': isViewed,
      };

  Story copyWith({
    String? id,
    User? user,
    String? imageUrl,
    String? videoUrl,
    DateTime? createdAt,
    bool? isViewed,
  }) {
    return Story(
      id: id ?? this.id,
      user: user ?? this.user,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      createdAt: createdAt ?? this.createdAt,
      isViewed: isViewed ?? this.isViewed,
    );
  }
}
