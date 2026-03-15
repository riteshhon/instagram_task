import '../models/models.dart';
import 'base_api_service.dart';

/// API service for posts feed (get posts from JSON).
class PostService extends BaseApiService {
  static const String _postsFeedPath = 'assets/json/posts_feed.json';
  static const int _pageSize = 10;

  List<Post>? _cachedPosts;

  /// Loads full posts list from JSON (cached).
  Future<List<Post>> _getAllPosts() async {
    if (_cachedPosts != null) return _cachedPosts!;
    final data = await getJsonFromAsset(_postsFeedPath);
    final list = data['posts'] as List<dynamic>? ?? [];
    _cachedPosts = list
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cachedPosts!;
  }

  /// Fetches the posts feed (first page only) for initial load.
  Future<List<Post>> getPostsFeed() async {
    return getPostsFeedPage(0);
  }

  /// Fetches a page of [pageSize] posts. Pages beyond the list length cycle with unique ids.
  Future<List<Post>> getPostsFeedPage(int page, {int pageSize = _pageSize}) async {
    final all = await _getAllPosts();
    if (all.isEmpty) return [];
    final start = page * pageSize;
    final result = <Post>[];
    for (var i = 0; i < pageSize; i++) {
      final index = (start + i) % all.length;
      final post = all[index];
      final uniqueId = start + i < all.length
          ? post.id
          : '${post.id}_p${page}_$i';
      result.add(post.copyWith(id: uniqueId));
    }
    return result;
  }

  /// Fetches a single post by id (from current feed; for demo we filter).
  Future<Post?> getPostById(String postId) async {
    final posts = await _getAllPosts();
    try {
      return posts.firstWhere((p) => p.id == postId);
    } catch (_) {
      return null;
    }
  }
}
