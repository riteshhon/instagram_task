import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../constants/logged_in_user.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../providers/feed_provider.dart';
import '../../../utils/format_utils.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post});

  final Post post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final feed = context.watch<FeedProvider>();
    final hasMultipleImages = post.imageUrls.length > 1;
    final currentPage = feed.getPostCurrentPage(post.id);

    return Container(
      margin: EdgeInsets.only(bottom: 12.w),
      color: AppTheme.primaryDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PostHeader(author: post.author, createdAt: post.createdAt),
          _PostImageSlider(
            imageUrls: post.imageUrls,
            pageController: _pageController,
            currentPage: currentPage,
            onPageChanged: (v) => feed.setPostCurrentPage(post.id, v),
            hasMultipleImages: hasMultipleImages,
            onDoubleTapLike: () => feed.toggleLike(post.id),
          ),
          _PostActions(
            post: post,
            onLike: () => feed.toggleLike(post.id),
            onComment: () => _showCommentsBottomSheet(context, post, feed),
            onShare: () => feed.sharePost(post.id),
            onSend: () => feed.sendPost(post.id),
            onSave: () => feed.toggleSave(post.id),
          ),
          if (post.likesCount > 0) _LikedByLine(post: post),
          if (post.caption != null && post.caption!.isNotEmpty)
            _PostCaption(
              postId: post.id,
              username: post.author.username,
              caption: post.caption!,
            ),
        ],
      ),
    );
  }

  void _showCommentsBottomSheet(
    BuildContext context,
    Post post,
    FeedProvider feed,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsBottomSheet(post: post, feed: feed),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.author, required this.createdAt});

  final User author;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final avatarSize = 36.w;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: AppTheme.cardDark,
            backgroundImage: author.avatarUrl != null
                ? CachedNetworkImageProvider(author.avatarUrl!)
                : null,
            child: author.avatarUrl == null
                ? Text(
                    (author.username.isNotEmpty ? author.username[0] : '?')
                        .toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.onSurfaceDark,
                      fontSize: 16.sp,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        author.username,
                        style: TextStyle(
                          color: AppTheme.onSurfaceDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (author.isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(
                        PhosphorIconsFill.checkCircle,
                        size: 12.h,
                        color: AppTheme.verifiedBlue,
                      ),
                    ],
                  ],
                ),
                Text(
                  formatTimeAgoLong(createdAt),
                  style: TextStyle(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.more_horiz_outlined,
              color: AppTheme.onSurfaceDark,
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 20.w, minHeight: 20.h),
          ),
        ],
      ),
    );
  }
}

class _PostImageSlider extends StatefulWidget {
  const _PostImageSlider({
    required this.imageUrls,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.hasMultipleImages,
    required this.onDoubleTapLike,
  });

  final List<String> imageUrls;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final bool hasMultipleImages;
  final VoidCallback onDoubleTapLike;

  @override
  State<_PostImageSlider> createState() => _PostImageSliderState();
}

class _PostImageSliderState extends State<_PostImageSlider> {
  final GlobalKey _imageStackKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  Rect? _imageRect;
  String? _zoomingImageUrl;

  void _onScaleStart(ScaleStartDetails details) {
    final box = _imageStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final offset = box.localToGlobal(Offset.zero);
    _imageRect = offset & box.size;
    _zoomingImageUrl = widget.imageUrls[widget.currentPage];
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_imageRect == null || _zoomingImageUrl == null) return;
    if (details.scale > 1.0 && _overlayEntry == null && context.mounted) {
      _overlayEntry = OverlayEntry(
        builder: (context) => _PinchZoomOverlayContent(
          imageUrl: _zoomingImageUrl!,
          initialRect: _imageRect!,
          onRemove: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: AppTheme.cardDark,
          child: const Center(
            child: Icon(
              PhosphorIconsRegular.imageSquare,
              size: 48,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    const Color indicatorPurple = Color(0xFFA855F7);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: GestureDetector(
            onDoubleTap: widget.onDoubleTapLike,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              key: _imageStackKey,
              children: [
                PageView.builder(
                  controller: widget.pageController,
                  onPageChanged: widget.onPageChanged,
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: widget.imageUrls[index],
                      fit: BoxFit.cover,
                      memCacheWidth: 800,
                      memCacheHeight: 800,
                      placeholder: (_, _) =>
                          Container(color: AppTheme.cardDark),
                      errorWidget: (_, _, _) => const Center(
                        child: Icon(
                          PhosphorIconsRegular.imageBroken,
                          size: 48,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
                if (widget.hasMultipleImages)
                  Positioned(
                    top: 12.w,
                    right: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.currentPage + 1}/${widget.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.hasMultipleImages)
          Padding(
            padding: EdgeInsets.only(top: 10.w, bottom: 4.w),
            child: _CarouselDots(
              key: ValueKey<int>(widget.currentPage),
              pageCount: widget.imageUrls.length,
              currentPage: widget.currentPage,
              color: indicatorPurple,
            ),
          ),
        if (!widget.hasMultipleImages) 8.verticalSpace,
      ],
    );
  }
}

/// Full-screen overlay: pinch-to-zoom and pan over the UI; on release animates back to [initialRect] then removes.
class _PinchZoomOverlayContent extends StatefulWidget {
  const _PinchZoomOverlayContent({
    required this.imageUrl,
    required this.initialRect,
    required this.onRemove,
  });

  final String imageUrl;
  final Rect initialRect;
  final VoidCallback onRemove;

  @override
  State<_PinchZoomOverlayContent> createState() =>
      _PinchZoomOverlayContentState();
}

class _PinchZoomOverlayContentState extends State<_PinchZoomOverlayContent>
    with TickerProviderStateMixin {
  final TransformationController _transformController =
      TransformationController();
  final ValueNotifier<bool> _animatingBackNotifier = ValueNotifier<bool>(false);
  int _activePointers = 0;
  late AnimationController _animController;
  late Animation<double> _leftAnim;
  late Animation<double> _topAnim;
  late Animation<double> _widthAnim;
  late Animation<double> _heightAnim;

  void _onPointerDown(PointerDownEvent event) {
    _activePointers++;
  }

  void _onPointerUp(PointerUpEvent event) {
    _activePointers--;
    if (_activePointers <= 0) {
      _activePointers = 0;
      _startAnimateBack();
    }
  }

  void _startAnimateBack() {
    if (_animatingBackNotifier.value || !mounted) return;
    final m = _transformController.value;
    final w = widget.initialRect.width;
    final h = widget.initialRect.height;
    final currentLeft = m.storage[12];
    final currentTop = m.storage[13];
    final scaleX = m.storage[0].abs();
    final scaleY = m.storage[5].abs();
    final currentWidth = w * scaleX;
    final currentHeight = h * scaleY;
    if (currentWidth.isFinite &&
        currentHeight.isFinite &&
        currentWidth > 0 &&
        currentHeight > 0) {
      _animatingBackNotifier.value = true;
      _animController.dispose();
      _animController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 280),
      );
      final curve = CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      );
      _leftAnim = Tween<double>(
        begin: currentLeft,
        end: widget.initialRect.left,
      ).animate(curve);
      _topAnim = Tween<double>(
        begin: currentTop,
        end: widget.initialRect.top,
      ).animate(curve);
      _widthAnim = Tween<double>(
        begin: currentWidth,
        end: widget.initialRect.width,
      ).animate(curve);
      _heightAnim = Tween<double>(
        begin: currentHeight,
        end: widget.initialRect.height,
      ).animate(curve);
      _animController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onRemove();
        }
      });
      _animController.forward(from: 0);
    } else {
      widget.onRemove();
    }
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _leftAnim = AlwaysStoppedAnimation<double>(widget.initialRect.left);
    _topAnim = AlwaysStoppedAnimation<double>(widget.initialRect.top);
    _widthAnim = AlwaysStoppedAnimation<double>(widget.initialRect.width);
    _heightAnim = AlwaysStoppedAnimation<double>(widget.initialRect.height);
  }

  @override
  void dispose() {
    _animatingBackNotifier.dispose();
    _transformController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _animatingBackNotifier,
      builder: (context, animatingBack, _) {
        if (animatingBack) {
          return AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.black54),
                  Positioned(
                    left: _leftAnim.value,
                    top: _topAnim.value,
                    width: _widthAnim.value,
                    height: _heightAnim.value,
                    child: ClipRect(
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.cover,
                        width: _widthAnim.value,
                        height: _heightAnim.value,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
        return Listener(
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: Colors.black54),
              Center(
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.5,
                  maxScale: 5.0,
                  panEnabled: true,
                  scaleEnabled: true,
                  panAxis: PanAxis.free,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  clipBehavior: Clip.none,
                  child: SizedBox(
                    width: widget.initialRect.width,
                    height: widget.initialRect.height,
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: AppTheme.cardDark),
                      errorWidget: (_, _, _) => const Center(
                        child: Icon(
                          PhosphorIconsRegular.imageBroken,
                          size: 48,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Dot indicator: one per page. Pattern from center outward: 3 full → 1 little tiny each side → 1 very tiny each side (both start and end).
class _CarouselDots extends StatelessWidget {
  const _CarouselDots({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.color,
  });

  final int pageCount;
  final int currentPage;
  final Color color;

  static const double _fullSize = 6.0;
  static const double _littleTinySize = 3.5;
  static const double _veryTinySize = 2.0;
  static const _duration = Duration(milliseconds: 200);
  static const _lightOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 0) return const SizedBox.shrink();
    if (pageCount == 1) {
      return _buildDot(context, _fullSize, true);
    }

    final scale = 1.0.w;
    const margin = 2.0;
    final cellW = (margin * 2) + _fullSize;

    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (i) {
          final distance = (i - currentPage).abs();
          // Center: 3 full; then 1 little tiny each side; then 1 very tiny each side
          final size = distance <= 1
              ? _fullSize
              : (distance == 2 ? _littleTinySize : _veryTinySize);
          final isSelected = i == currentPage;
          return SizedBox(
            width: scale * cellW,
            child: Center(child: _buildDot(context, size, isSelected)),
          );
        }),
      ),
    );
  }

  Widget _buildDot(BuildContext context, double size, bool isSelected) {
    final scale = 1.0.w;
    final dotColor = isSelected
        ? color
        : Colors.white.withValues(alpha: _lightOpacity);
    return AnimatedContainer(
      duration: _duration,
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.symmetric(horizontal: scale * 2),
      width: scale * size,
      height: scale * size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
    );
  }
}

class _PostActions extends StatelessWidget {
  const _PostActions({
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSend,
    required this.onSave,
  });

  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSend;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final padding = 12.w;
    final countStyle = TextStyle(
      color: AppTheme.onSurfaceDark,
      fontSize: 11.sp,
      fontWeight: FontWeight.bold,
    );

    final iconSize = 22.h;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          post.isLikedByMe
                              ? PhosphorIconsFill.heart
                              : PhosphorIconsRegular.heart,
                          color: post.isLikedByMe
                              ? AppTheme.accentRed
                              : AppTheme.onSurfaceDark,
                          size: iconSize,
                          weight: 10,
                        ),
                        onPressed: onLike,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,

                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      2.horizontalSpace,
                      Text(
                        formatCount(post.likesCount),
                        style: countStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  12.horizontalSpace,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          PhosphorIconsRegular.chatCircle,
                          color: AppTheme.onSurfaceDark,
                          size: iconSize,
                        ),
                        onPressed: onComment,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      2.horizontalSpace,
                      Text(
                        formatCountWithComma(post.commentsCount),
                        style: countStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  12.horizontalSpace,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          LucideIcons.repeat,
                          color: AppTheme.onSurfaceDark,
                          size: iconSize,
                        ),
                        onPressed: onShare,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      2.horizontalSpace,
                      Text(
                        formatCountWithComma(post.sharesCount),
                        style: countStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  12.horizontalSpace,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          IconlyLight.send,
                          color: AppTheme.onSurfaceDark,
                          size: iconSize,
                        ),
                        onPressed: onSend,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      2.horizontalSpace,
                      Text(
                        formatCount(post.sendsCount),
                        style: countStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              post.isSavedByMe
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: AppTheme.onSurfaceDark,
              size: iconSize + 2,
            ),
            onPressed: onSave,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _LikedByLine extends StatelessWidget {
  const _LikedByLine({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final likers = post.likes != null && post.likes!.isNotEmpty
        ? post.likes!.map((e) => e.user).toList()
        : <User>[];
    final firstLiker = likers.isNotEmpty ? likers.first : null;
    final displayLikers = likers.take(3).toList();

    final avatarSize = 18.w;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          if (displayLikers.isNotEmpty) ...[
            SizedBox(
              width:
                  (displayLikers.length - 1) * (avatarSize * 0.6) + avatarSize,
              height: avatarSize,
              child: Stack(
                children: List.generate(displayLikers.length, (i) {
                  final user = displayLikers[i];
                  return Positioned(
                    left: (i * (avatarSize * 0.6)).toDouble(),
                    child: Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryDark,
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: user.avatarUrl != null
                            ? CachedNetworkImage(
                                imageUrl: user.avatarUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => Icon(
                                  PhosphorIconsRegular.user,
                                  size: 14.w,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              )
                            : Icon(
                                PhosphorIconsRegular.user,
                                size: 14.w,
                                color: AppTheme.onSurfaceVariant,
                              ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(width: 4.w),
          ],
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: AppTheme.onSurfaceDark,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(text: 'Liked by '),
                  TextSpan(
                    text: firstLiker?.username ?? 'others',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' and '),
                  const TextSpan(
                    text: 'others',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCaption extends StatelessWidget {
  const _PostCaption({
    required this.postId,
    required this.username,
    required this.caption,
  });

  final String postId;
  final String username;
  final String caption;

  /// Roughly one line of caption; beyond this we show "more".
  static const int _oneLineChars = 50;

  /// Words starting with # get light purple; rest use [baseStyle].
  static List<TextSpan> _captionSpans(String text, TextStyle baseStyle) {
    final hashtagStyle = baseStyle.copyWith(color: AppTheme.hashtagPurple);
    final spans = <TextSpan>[];
    final words = text.split(' ');
    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.startsWith('#')) {
        spans.add(TextSpan(text: word, style: hashtagStyle));
      } else {
        spans.add(TextSpan(text: word, style: baseStyle));
      }
      if (i < words.length - 1) {
        spans.add(TextSpan(text: ' ', style: baseStyle));
      }
    }
    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  }

  @override
  Widget build(BuildContext context) {
    return Selector<FeedProvider, bool>(
      selector: (_, feed) => feed.isCaptionExpanded(postId),
      builder: (context, isExpanded, _) {
        final needsExpand = caption.length > _oneLineChars;
        final displayCaption = needsExpand && !isExpanded
            ? '${caption.substring(0, _oneLineChars)}...'
            : caption;

        final baseStyle = TextStyle(
          color: AppTheme.onSurfaceDark,
          fontSize: 11.sp,
        );
        final linkStyle = TextStyle(
          color: AppTheme.onSurfaceVariant,
          fontSize: 12.sp,
        );

        final usernameSpan = TextSpan(
          text: '$username ',
          style: baseStyle.copyWith(fontWeight: FontWeight.w600),
        );

        void onTapCaption() =>
            context.read<FeedProvider>().toggleCaptionExpanded(postId);

        if (isExpanded) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4),
            child: GestureDetector(
              onTap: onTapCaption,
              behavior: HitTestBehavior.opaque,
              child: RichText(
                text: TextSpan(
                  style: baseStyle,
                  children: [
                    usernameSpan,
                    ..._captionSpans(caption, baseStyle),
                  ],
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2),
          child: GestureDetector(
            onTap: needsExpand ? onTapCaption : null,
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: baseStyle,
                      children: [
                        usernameSpan,
                        ..._captionSpans(displayCaption, baseStyle),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (needsExpand)
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: GestureDetector(
                      onTap: onTapCaption,
                      behavior: HitTestBehavior.opaque,
                      child: Text('more', style: linkStyle),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Dark-themed comments bottom sheet matching Instagram style.
class _CommentsBottomSheet extends StatefulWidget {
  const _CommentsBottomSheet({required this.post, required this.feed});

  final Post post;
  final FeedProvider feed;

  @override
  State<_CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<_CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, feed, _) {
        Post post = widget.post;
        for (final p in feed.posts) {
          if (p.id == widget.post.id) {
            post = p;
            break;
          }
        }
        void submitComment() {
          final text = _controller.text.trim();
          if (text.isEmpty) return;
          widget.feed.addComment(widget.post.id, text, kLoggedInUser);
          _controller.clear();
        }

        return _CommentsBottomSheetContent(
          post: post,
          feed: widget.feed,
          controller: _controller,
          onSubmit: submitComment,
        );
      },
    );
  }
}

class _CommentsBottomSheetContent extends StatefulWidget {
  const _CommentsBottomSheetContent({
    required this.post,
    required this.feed,
    required this.controller,
    required this.onSubmit,
  });

  final Post post;
  final FeedProvider feed;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  State<_CommentsBottomSheetContent> createState() =>
      _CommentsBottomSheetContentState();
}

class _CommentsBottomSheetContentState
    extends State<_CommentsBottomSheetContent> {
  static const _quickEmojis = ['❤️', '🙌', '🔥', '👏', '😢', '😍', '🤔', '😂'];

  /// Comment ids whose replies are expanded. Uses ValueNotifier to avoid setState.
  final ValueNotifier<Set<String>> _expandedReplyIdsNotifier =
      ValueNotifier<Set<String>>({});

  void _toggleReplies(String commentId) {
    final next = Set<String>.from(_expandedReplyIdsNotifier.value);
    if (next.contains(commentId)) {
      next.remove(commentId);
    } else {
      next.add(commentId);
    }
    _expandedReplyIdsNotifier.value = next;
  }

  @override
  void dispose() {
    _expandedReplyIdsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final comments = post.comments ?? [];
    final sheetBg = AppTheme.cardDark;
    final textColor = AppTheme.onSurfaceDark;
    final secondaryColor = AppTheme.onSurfaceVariant;
    final sheetHeight =
        MediaQuery.sizeOf(context).height *
        (MediaQuery.sizeOf(context).height < 600 ? 0.7 : 0.7);

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          15.verticalSpace,
          Container(
            width: 35.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(180.r),
            ),
          ),
          8.verticalSpace,
          Text(
            'Comments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          16.verticalSpace,
          Expanded(
            child: ValueListenableBuilder<Set<String>>(
              valueListenable: _expandedReplyIdsNotifier,
              builder: (context, expandedReplyIds, _) {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final c = comments[index];
                    final replyCount = c.replies?.length ?? 0;
                    final isExpanded = expandedReplyIds.contains(c.id);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14.w,
                                backgroundColor: AppTheme.dividerDark,
                                backgroundImage: c.user.avatarUrl != null
                                    ? CachedNetworkImageProvider(
                                        c.user.avatarUrl!,
                                      )
                                    : null,
                                child: c.user.avatarUrl == null
                                    ? Text(
                                        (c.user.username.isNotEmpty
                                                ? c.user.username[0]
                                                : '?')
                                            .toUpperCase(),
                                        style: TextStyle(color: textColor),
                                      )
                                    : null,
                              ),
                              8.horizontalSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          c.user.username,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                        3.horizontalSpace,
                                        Text(
                                          formatTimeAgo(c.createdAt),
                                          style: TextStyle(
                                            color: secondaryColor,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.text,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                    SizedBox(height: 4.w),
                                    Text(
                                      'Reply',
                                      style: TextStyle(
                                        color: secondaryColor,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                    if (replyCount > 0) ...[
                                      SizedBox(height: 4.w),
                                      GestureDetector(
                                        onTap: () => _toggleReplies(c.id),
                                        child: Text(
                                          isExpanded
                                              ? 'Hide repl${replyCount == 1 ? 'y' : 'ies'}'
                                              : 'View $replyCount more repl${replyCount == 1 ? 'y' : 'ies'}',
                                          style: TextStyle(
                                            color: secondaryColor,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Icon(
                                    PhosphorIconsRegular.heart,
                                    size: 16.w,
                                    color: secondaryColor,
                                  ),
                                  if (c.likesCount > 0)
                                    Text(
                                      formatCount(c.likesCount),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: secondaryColor,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          if (isExpanded &&
                              c.replies != null &&
                              c.replies!.isNotEmpty) ...[
                            SizedBox(height: 12.w),
                            ...c.replies!.map(
                              (reply) => _ReplyTile(
                                reply: reply,
                                textColor: textColor,
                                secondaryColor: secondaryColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _CommentInputBar(
            currentUser: kLoggedInUser,
            authorUsername: post.author.username,
            controller: widget.controller,
            quickEmojis: _quickEmojis,
            onEmojiTap: (emoji) {
              widget.controller.text = widget.controller.text + emoji;
              widget.controller.selection = TextSelection.fromPosition(
                TextPosition(offset: widget.controller.text.length),
              );
            },
            onSubmit: widget.onSubmit,
            sheetBg: sheetBg,
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),
        ],
      ),
    );
  }
}

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({
    required this.reply,
    required this.textColor,
    required this.secondaryColor,
  });

  final Comment reply;
  final Color textColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 30.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14.w,
            backgroundColor: AppTheme.dividerDark,
            backgroundImage: reply.user.avatarUrl != null
                ? CachedNetworkImageProvider(reply.user.avatarUrl!)
                : null,
            child: reply.user.avatarUrl == null
                ? Text(
                    (reply.user.username.isNotEmpty
                            ? reply.user.username[0]
                            : '?')
                        .toUpperCase(),
                    style: TextStyle(color: textColor, fontSize: 10.sp),
                  )
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.user.username,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                    3.horizontalSpace,
                    Text(
                      formatTimeAgo(reply.createdAt),
                      style: TextStyle(color: secondaryColor, fontSize: 11.sp),
                    ),
                  ],
                ),
                SizedBox(height: 2.w),
                Text(
                  reply.text,
                  style: TextStyle(color: textColor, fontSize: 11.sp),
                ),
                SizedBox(height: 2.w),
                Text(
                  'Reply',
                  style: TextStyle(color: secondaryColor, fontSize: 11.sp),
                ),
              ],
            ),
          ),
          if (reply.likesCount > 0)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIconsRegular.heart,
                  size: 16.w,
                  color: secondaryColor,
                ),
                SizedBox(width: 2.w),
                Text(
                  formatCount(reply.likesCount),
                  style: TextStyle(fontSize: 10.sp, color: secondaryColor),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CommentInputBar extends StatefulWidget {
  const _CommentInputBar({
    required this.currentUser,
    required this.authorUsername,
    required this.controller,
    required this.quickEmojis,
    required this.onEmojiTap,
    required this.onSubmit,
    required this.sheetBg,
    required this.textColor,
    required this.secondaryColor,
  });

  final User currentUser;
  final String authorUsername;
  final TextEditingController controller;
  final List<String> quickEmojis;
  final ValueChanged<String> onEmojiTap;
  final VoidCallback onSubmit;
  final Color sheetBg;
  final Color textColor;
  final Color secondaryColor;

  @override
  State<_CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<_CommentInputBar> {
  @override
  Widget build(BuildContext context) {
    final horizontalPad = 16.w;
    final verticalPad = 8.w;
    final lightWhiteBorder = Colors.white.withValues(alpha: 0.25);
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final hasText = widget.controller.text.trim().isNotEmpty;
        return Container(
          padding: EdgeInsets.only(
            left: horizontalPad,
            right: horizontalPad,
            top: verticalPad,
            bottom: bottomPad > 0 ? bottomPad : verticalPad,
          ),
          color: widget.sheetBg,
          child: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: widget.quickEmojis
                      .map(
                        (e) => Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onEmojiTap(e),
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: Text(e, style: TextStyle(fontSize: 22.sp)),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 8.w),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16.w,
                      backgroundColor: widget.secondaryColor,
                      backgroundImage: widget.currentUser.avatarUrl != null
                          ? CachedNetworkImageProvider(
                              widget.currentUser.avatarUrl!,
                            )
                          : null,
                      child: widget.currentUser.avatarUrl == null
                          ? Text(
                              widget.currentUser.username.isNotEmpty
                                  ? widget.currentUser.username[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: widget.textColor,
                                fontSize: 14.sp,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 12.sp,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Add a comment for ${widget.authorUsername}',
                          hintStyle: TextStyle(color: widget.secondaryColor),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.w,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: lightWhiteBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: lightWhiteBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: lightWhiteBorder,
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: hasText
                              ? GestureDetector(
                                  onTap: widget.onSubmit,
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 8.w),
                                    child: Icon(
                                      PhosphorIconsRegular.paperPlaneTilt,
                                      color: widget.textColor,
                                      size: 22.w,
                                    ),
                                  ),
                                )
                              : Icon(
                                  PhosphorIconsRegular.smiley,
                                  color: widget.secondaryColor,
                                  size: 22.w,
                                ),
                        ),
                        onSubmitted: (_) => widget.onSubmit(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
