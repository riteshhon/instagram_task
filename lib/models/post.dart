import 'user.dart';
import 'like.dart';
import 'comment.dart';

/// Model for a post in the feed (images slider, likes, comments, share, send, save).
class Post {
  final String id;
  final User author;
  final List<String> imageUrls;
  final String? caption;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int sendsCount;
  final DateTime createdAt;
  final bool isLikedByMe;
  final bool isSavedByMe;
  final List<Like>? likes;
  final List<Comment>? comments;

  const Post({
    required this.id,
    required this.author,
    required this.imageUrls,
    this.caption,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.sendsCount = 0,
    required this.createdAt,
    this.isLikedByMe = false,
    this.isSavedByMe = false,
    this.likes,
    this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      caption: json['caption'] as String?,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      sharesCount: (json['sharesCount'] as num?)?.toInt() ?? 0,
      sendsCount: (json['sendsCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isLikedByMe: json['isLikedByMe'] as bool? ?? false,
      isSavedByMe: json['isSavedByMe'] as bool? ?? false,
      likes: (json['likes'] as List<dynamic>?)
          ?.map((e) => Like.fromJson(e as Map<String, dynamic>))
          .toList(),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author.toJson(),
        'imageUrls': imageUrls,
        'caption': caption,
        'likesCount': likesCount,
        'commentsCount': commentsCount,
        'sharesCount': sharesCount,
        'sendsCount': sendsCount,
        'createdAt': createdAt.toIso8601String(),
        'isLikedByMe': isLikedByMe,
        'isSavedByMe': isSavedByMe,
        'likes': likes?.map((e) => e.toJson()).toList(),
        'comments': comments?.map((e) => e.toJson()).toList(),
      };

  Post copyWith({
    String? id,
    User? author,
    List<String>? imageUrls,
    String? caption,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? sendsCount,
    DateTime? createdAt,
    bool? isLikedByMe,
    bool? isSavedByMe,
    List<Like>? likes,
    List<Comment>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      imageUrls: imageUrls ?? this.imageUrls,
      caption: caption ?? this.caption,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      sendsCount: sendsCount ?? this.sendsCount,
      createdAt: createdAt ?? this.createdAt,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isSavedByMe: isSavedByMe ?? this.isSavedByMe,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}
