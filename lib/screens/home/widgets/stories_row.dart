import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/logged_in_user.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../providers/feed_provider.dart';

class StoriesRow extends StatelessWidget {
  const StoriesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, feed, _) {
        if (feed.storiesLoading && feed.stories.isEmpty) {
          return _StoriesLoadingShimmer();
        }

        final size = 68.w;
        final padding = 12.w;
        final gap = 6.w;
        final labelHeight = 20.w;
        final verticalPad = 16.w;
        final rowHeight = size + gap * 2 + labelHeight + verticalPad;

        return SizedBox(
          height: rowHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: verticalPad / 2,
            ),
            itemCount: feed.stories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _YourStoryCircle(user: kLoggedInUser, size: size);
              }
              final story = feed.stories[index - 1];
              return _StoryCircle(story: story, size: size);
            },
          ),
        );
      },
    );
  }
}

class _StoriesLoadingShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = 68.w;
    final padding = 12.w;
    final gap = 6.w;
    const labelHeight = 10.0;
    const verticalPad = 12.0;
    final rowHeight = (size + 4) + gap + labelHeight + (verticalPad * 2);

    return SizedBox(
      height: rowHeight,
      child: Shimmer.fromColors(
        baseColor: AppTheme.cardDark,
        highlightColor: AppTheme.dividerDark,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: verticalPad,
          ),
          itemCount: 6,
          separatorBuilder: (_, _) => SizedBox(width: 12.w),
          itemBuilder: (_, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size + 4,
                height: size + 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(height: gap),
              Container(
                width: size * 0.8,
                height: labelHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YourStoryCircle extends StatelessWidget {
  const _YourStoryCircle({required this.user, required this.size});

  final User user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size + 4,
          height: size + 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size + 4,
                height: size + 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.dividerDark, width: 2),
                ),
              ),
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cardDark,
                ),
                child: ClipOval(
                  child: user.avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: user.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Center(
                            child: Text(
                              user.username.isNotEmpty
                                  ? user.username[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: AppTheme.onSurfaceVariant,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Center(
                            child: Text(
                              user.username.isNotEmpty
                                  ? user.username[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: AppTheme.onSurfaceVariant,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            user.username.isNotEmpty
                                ? user.username[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: AppTheme.onSurfaceVariant,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: size * 0.36,
                  height: size * 0.36,
                  decoration: BoxDecoration(
                    color: AppTheme.verifiedBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryDark, width: 2),
                  ),
                  child: const Icon(
                    PhosphorIconsRegular.plus,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.w),
        SizedBox(
          height: 18.w,
          width: size + 16.w,
          child: Text(
            "Your story",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 11.sp),
          ),
        ),
      ],
    );
  }
}

class _StoryCircle extends StatelessWidget {
  const _StoryCircle({required this.story, required this.size});

  final Story story;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isViewed = story.isViewed;
    final avatarUrl = story.user.avatarUrl ?? story.imageUrl;

    return GestureDetector(
      onTap: () => context.read<FeedProvider>().markStoryViewed(story.id),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: size + 6,
              height: size + 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isViewed
                    ? null
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.storyGradientGreen,
                          AppTheme.storyGradientEnd,
                          AppTheme.storyGradientMid,
                          AppTheme.storyGradientStart,
                        ],
                        stops: [0.0, 0.33, 0.66, 1.0],
                      ),
                border: isViewed
                    ? Border.all(color: AppTheme.dividerDark, width: 2)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryDark,
                  ),
                  child: ClipOval(
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: avatarUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                Container(color: AppTheme.cardDark),
                            errorWidget: (_, _, _) => Icon(
                              PhosphorIconsRegular.user,
                              size: size * 0.5,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          )
                        : Icon(
                            PhosphorIconsRegular.user,
                            size: size * 0.5,
                            color: AppTheme.onSurfaceVariant,
                          ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 4.w),
          SizedBox(
            height: 18.w,
            width: size + 8.w,
            child: Text(
              story.user.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.onSurfaceDark, fontSize: 10.sp),
            ),
          ),
        ],
      ),
    );
  }
}
