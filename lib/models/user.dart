/// Model for user (post author, story author, commenter).
class User {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final bool isVerified;

  const User({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'isVerified': isVerified,
      };
}
