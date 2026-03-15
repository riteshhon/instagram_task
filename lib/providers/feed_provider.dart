import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/services.dart';

class FeedProvider with ChangeNotifier {
  FeedProvider({PostService? postService, StoryService? storyService})
    : _postService = postService ?? PostService(),
      _storyService = storyService ?? StoryService();

  final PostService _postService;
  final StoryService _storyService;

  List<Post> _posts = [];
  List<Story> _stories = [];
  bool _postsLoading = false;
  bool _storiesLoading = false;
  bool _postsLoadingMore = false;
  String? _postsError;
  String? _storiesError;
  int _postsNextPage = 0;

  /// Shimmer shown for initial load; kept visible for at least [shimmerMinDuration].
  bool _showShimmer = false;
  Timer? _shimmerTimer;
  DateTime? _shimmerLoadStartedAt;

  /// Minimum time to show shimmer so user always sees loading state.
  static const Duration shimmerMinDuration = Duration(seconds: 2);

  /// Per-post carousel page index (postId -> page).
  final Map<String, int> _postCurrentPage = {};

  /// Per-post caption expanded state (postId -> expanded).
  final Map<String, bool> _captionExpanded = {};

  List<Post> get posts => List.unmodifiable(_posts);
  List<Story> get stories => List.unmodifiable(_stories);
  bool get postsLoading => _postsLoading;
  bool get storiesLoading => _storiesLoading;
  bool get postsLoadingMore => _postsLoadingMore;
  String? get postsError => _postsError;
  String? get storiesError => _storiesError;
  bool get showShimmer => _showShimmer;

  int getPostCurrentPage(String postId) => _postCurrentPage[postId] ?? 0;
  void setPostCurrentPage(String postId, int page) {
    if ((_postCurrentPage[postId] ?? 0) == page) return;
    _postCurrentPage[postId] = page;
    notifyListeners();
  }

  bool isCaptionExpanded(String postId) => _captionExpanded[postId] ?? false;
  void toggleCaptionExpanded(String postId) {
    _captionExpanded[postId] = !(_captionExpanded[postId] ?? false);
    notifyListeners();
  }

  void _hideShimmer() {
    _showShimmer = false;
    _shimmerTimer?.cancel();
    _shimmerTimer = null;
    _shimmerLoadStartedAt = null;
    notifyListeners();
  }

  void _scheduleShimmerHide() {
    _shimmerTimer?.cancel();
    final startedAt = _shimmerLoadStartedAt;
    if (startedAt == null) {
      _hideShimmer();
      return;
    }
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = shimmerMinDuration.inMilliseconds - elapsed.inMilliseconds;
    if (remaining <= 0) {
      _hideShimmer();
      return;
    }
    _shimmerTimer = Timer(Duration(milliseconds: remaining), () {
      _hideShimmer();
    });
  }

  /// Loads first page of posts (initial load). Shimmer shows immediately and stays for at least 2 seconds.
  Future<void> loadPostsFeed() async {
    _postsLoading = true;
    _postsError = null;
    _postsNextPage = 0;
    _showShimmer = true;
    _shimmerLoadStartedAt = DateTime.now();
    notifyListeners();

    try {
      _posts = await _postService.getPostsFeedPage(0);
      _postsError = null;
      _postsNextPage = 1;
    } catch (e, st) {
      _postsError = e.toString();
      if (kDebugMode) {
        debugPrint('FeedProvider.loadPostsFeed error: $e');
        debugPrint(st.toString());
      }
    } finally {
      _postsLoading = false;
      _scheduleShimmerHide();
      notifyListeners();
    }
  }

  /// Loads next page of 10 posts and appends. Call when user is ~2 posts from bottom.
  /// Includes a 3.5s delay so the loading indicator is visible.
  Future<void> loadMorePosts() async {
    if (_postsLoadingMore || _postsLoading) return;
    _postsLoadingMore = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      final next = await _postService.getPostsFeedPage(_postsNextPage);
      if (next.isNotEmpty) {
        _posts = [..._posts, ...next];
        _postsNextPage++;
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('FeedProvider.loadMorePosts error: $e');
        debugPrint(st.toString());
      }
    } finally {
      _postsLoadingMore = false;
      notifyListeners();
    }
  }

  /// Loads stories from JSON (API call).
  Future<void> loadStories() async {
    _storiesLoading = true;
    _storiesError = null;
    notifyListeners();

    try {
      _stories = await _storyService.getStories();
      _storiesError = null;
    } catch (e, st) {
      _storiesError = e.toString();
      if (kDebugMode) {
        debugPrint('FeedProvider.loadStories error: $e');
        debugPrint(st.toString());
      }
    } finally {
      _storiesLoading = false;
      notifyListeners();
    }
  }

  /// Loads both feed and stories.
  Future<void> loadFeed() async {
    await Future.wait([loadPostsFeed(), loadStories()]);
  }

  /// Toggle like on post (optimistic update).
  void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    _posts = List<Post>.from(_posts);
    final post = _posts[index];
    final newLiked = !post.isLikedByMe;
    _posts[index] = post.copyWith(
      isLikedByMe: newLiked,
      likesCount: post.likesCount + (newLiked ? 1 : -1),
    );
    notifyListeners();
  }

  /// Add a comment to a post (local only for demo).
  void addComment(String postId, String text, User currentUser) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    _posts = List<Post>.from(_posts);
    final post = _posts[index];
    final comment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      user: currentUser,
      text: text,
      createdAt: DateTime.now(),
    );
    final List<Comment> updatedComments = [
      ...(post.comments ?? <Comment>[]),
      comment,
    ];
    _posts[index] = post.copyWith(
      commentsCount: post.commentsCount + 1,
      comments: updatedComments,
    );
    notifyListeners();
  }

  /// Increment share count for a post.
  void sharePost(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    _posts = List<Post>.from(_posts);
    final post = _posts[index];
    _posts[index] = post.copyWith(sharesCount: post.sharesCount + 1);
    notifyListeners();
  }

  /// Increment send (DM) count for a post.
  void sendPost(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    _posts = List<Post>.from(_posts);
    final post = _posts[index];
    _posts[index] = post.copyWith(sendsCount: post.sendsCount + 1);
    notifyListeners();
  }

  /// Toggle save (bookmark) on a post.
  void toggleSave(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    _posts = List<Post>.from(_posts);
    final post = _posts[index];
    _posts[index] = post.copyWith(isSavedByMe: !post.isSavedByMe);
    notifyListeners();
  }

  /// Mark a story as viewed.
  void markStoryViewed(String storyId) {
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index < 0) return;
    _stories[index] = _stories[index].copyWith(isViewed: true);
    notifyListeners();
  }
}
