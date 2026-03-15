import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../providers/feed_provider.dart';
import '../widgets/feed_shimmer.dart';
import '../widgets/stories_row.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  static const double _loadMoreTriggerThreshold = 800;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (!position.hasContentDimensions || !position.hasPixels) return;
    if (position.maxScrollExtent <= _loadMoreTriggerThreshold) return;
    final threshold = position.maxScrollExtent - _loadMoreTriggerThreshold;
    if (position.pixels >= threshold) {
      context.read<FeedProvider>().loadMorePosts();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = width >= Breakpoints.tablet ? Breakpoints.large : null;
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child:
            Selector<
              FeedProvider,
              ({
                bool postsLoading,
                String? postsError,
                List<Post> posts,
                bool postsLoadingMore,
                bool showShimmer,
              })
            >(
              selector: (_, f) => (
                postsLoading: f.postsLoading,
                postsError: f.postsError,
                posts: f.posts,
                postsLoadingMore: f.postsLoadingMore,
                showShimmer: f.showShimmer,
              ),
              builder: (context, data, _) {
                final feed = context.read<FeedProvider>();
                final posts = data.posts;
                final postsLoadingMore = data.postsLoadingMore;
                final isLoadingEmpty = data.postsLoading && posts.isEmpty;
                // Show real app bar + shimmer content (no app bar loading state).
                if (isLoadingEmpty || data.showShimmer) {
                  return CustomScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    slivers: [
                      _buildAppBar(context),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: const FeedShimmer(),
                      ),
                    ],
                  );
                }
                if (posts.isEmpty && data.postsError == null) {
                  return Center(
                    child: Text(
                      'No posts yet',
                      style: TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }
                if (data.postsError != null && posts.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Center(
                      child: Text(
                        data.postsError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.accentRed,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  );
                }

                final postCount = posts.length + (postsLoadingMore ? 1 : 0);
                final listView = RefreshIndicator(
                  onRefresh: () => feed.loadFeed(),
                  color: AppTheme.onSurfaceDark,
                  backgroundColor: AppTheme.cardDark,
                  child: CustomScrollView(
                    controller: _scrollController,
                    cacheExtent: 2500,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      _buildAppBar(context),
                      const SliverToBoxAdapter(child: StoriesRow()),
                      SliverPadding(
                        padding: EdgeInsets.only(
                          bottom: postsLoadingMore
                              ? 24.w
                              : 56.w +
                                    MediaQuery.paddingOf(context).bottom +
                                    24.w,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= posts.length) {
                                return RepaintBoundary(
                                  child: _LoadingMoreIndicator(),
                                );
                              }
                              return RepaintBoundary(
                                child: PostCard(
                                  key: ValueKey(posts[index].id),
                                  post: posts[index],
                                ),
                              );
                            },
                            childCount: postCount,
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                            addSemanticIndexes: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                if (maxWidth != null) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: listView,
                    ),
                  );
                }
                return listView;
              },
            ),
      ),
      bottomNavigationBar: _BottomNavBar(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.primaryDark,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.add, color: AppTheme.onSurfaceDark, size: 28.h),
        onPressed: () {},
      ),
      title: Text(
        'Instagram',
        style: GoogleFonts.lobsterTwo(
          fontSize: 30.sp,
          fontWeight: FontWeight.w400,
          color: AppTheme.onSurfaceDark,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            PhosphorIconsRegular.heart,
            color: AppTheme.onSurfaceDark,
            size: 24.h,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32.w),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28.w,
            height: 28.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.onSurfaceDark,
              backgroundColor: AppTheme.dividerDark,
            ),
          ),
          SizedBox(height: 12.w),
          Text(
            'Loading more posts...',
            style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.primaryDark,
        border: Border(
          top: BorderSide(color: AppTheme.dividerDark, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: IconlyLight.home,
                selectedIcon: IconlyBold.home,
                selected: true,
              ),
              _NavItem(icon: IconlyLight.play),
              _NavItem(icon: IconlyLight.send),
              _NavItem(icon: LucideIcons.search),
              _NavItem(
                icon: LucideIcons.user,
                selectedIcon: PhosphorIconsFill.user,
                showDot: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    this.selectedIcon,
    this.selected = false,
    this.showDot = false,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final bool selected;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final iconSize = 26.w;
    final dotSize = 8.w;
    final displayIcon = (selected && selectedIcon != null)
        ? selectedIcon!
        : icon;
    return IconButton(
      onPressed: () {},
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            displayIcon,
            size: iconSize,
            color: selected
                ? AppTheme.onSurfaceDark
                : AppTheme.onSurfaceVariant,
          ),
          if (showDot)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: const BoxDecoration(
                  color: AppTheme.accentRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
