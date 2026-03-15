import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_theme.dart';

/// Shimmer placeholder for stories + post cards only. App bar is shown by the screen (no shimmer on app bar).
class FeedShimmer extends StatelessWidget {
  const FeedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryDark,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Shimmer.fromColors(
          baseColor: AppTheme.cardDark,
          highlightColor: AppTheme.dividerDark,
          enabled: true,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StoriesShimmer(),
                _PostCardShimmer(),
                _PostCardShimmer(),
                _PostCardShimmer(),
                SizedBox(height: 56.w + MediaQuery.paddingOf(context).bottom + 24.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Matches StoriesRow layout: size 68.w, padding 12.w, gap 6.w, labelHeight 20.w, verticalPad 16.w.
class _StoriesShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = 68.w;
    final padding = 12.w;
    final gap = 6.w;
    final labelHeight = 20.w;
    final verticalPad = 16.w;
    final rowHeight = size + gap * 2 + labelHeight + verticalPad;

    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: verticalPad / 2,
        ),
        itemCount: 7,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: gap),
            Container(
              width: size * 0.75,
              height: labelHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors PostCard structure from post_card.dart: _PostHeader, _PostImageSlider, _PostActions, _LikedByLine, _PostCaption.
class _PostCardShimmer extends StatelessWidget {
  static const double _padding = 12; // 12.w in post_card
  static const double _avatarSize = 36;
  static const double _headerVertical = 10;
  static const double _iconSize = 22;
  static const double _likedByAvatarSize = 18;
  static const double _carouselDotFullSize = 6;
  static const double _carouselPaddingTop = 10;
  static const double _carouselPaddingBottom = 4;
  static const double _singleImageSpace = 8;

  @override
  Widget build(BuildContext context) {
    final p = _padding.w;
    final avatarSize = _avatarSize.w;
    final iconSize = _iconSize.w;
    final likedByAvatar = _likedByAvatarSize.w;

    return Container(
      margin: EdgeInsets.only(bottom: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // _PostHeader: padding horizontal 12.w, vertical 10.w; avatar 36.w; 10.w gap; more_horiz 20.w
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: p,
              vertical: _headerVertical.w,
            ),
            child: Row(
              children: [
                _circle(avatarSize),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _box(90.w, 12.w),
                      SizedBox(height: 6.w),
                      _box(50.w, 10.w),
                    ],
                  ),
                ),
                SizedBox(width: 20.w, height: 20.w, child: _box(20.w, 20.w)),
              ],
            ),
          ),
          // _PostImageSlider: Column with AspectRatio 1, then dots or 8.verticalSpace
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(width: double.infinity, color: Colors.white),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: _carouselPaddingTop.w,
                  bottom: _carouselPaddingBottom.w,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circle(_carouselDotFullSize.w),
                    SizedBox(width: 4.w),
                    _circle(_carouselDotFullSize.w),
                    SizedBox(width: 4.w),
                    _circle(_carouselDotFullSize.w),
                  ],
                ),
              ),
              SizedBox(height: _singleImageSpace.w),
            ],
          ),
          // _PostActions: padding horizontal 12.w, vertical 8; icon 22.h + 2.w + count; 12.w between groups; bookmark 24.w
          Padding(
            padding: EdgeInsets.symmetric(horizontal: p, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _iconBox(iconSize),
                      SizedBox(width: 2.w),
                      _box(18.w, 11.w),
                      SizedBox(width: 12.w),
                      _iconBox(iconSize),
                      SizedBox(width: 2.w),
                      _box(22.w, 11.w),
                      SizedBox(width: 12.w),
                      _iconBox(iconSize),
                      SizedBox(width: 2.w),
                      _box(16.w, 11.w),
                      SizedBox(width: 12.w),
                      _iconBox(iconSize),
                      SizedBox(width: 2.w),
                      _box(14.w, 11.w),
                    ],
                  ),
                ),
                _iconBox(iconSize + 2.w),
              ],
            ),
          ),
          // _LikedByLine: padding horizontal 12.w; Stack of 3 avatars (18.w, left: i*10.8.w); 4.w; Expanded text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: p),
            child: Row(
              children: [
                SizedBox(
                  width: (2 * (likedByAvatar * 0.6)) + likedByAvatar,
                  height: likedByAvatar,
                  child: Stack(
                    children: [
                      Positioned(left: 0, child: _circle(likedByAvatar)),
                      Positioned(
                        left: likedByAvatar * 0.6,
                        child: _circle(likedByAvatar),
                      ),
                      Positioned(
                        left: likedByAvatar * 1.2,
                        child: _circle(likedByAvatar),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(child: _box(120.w, 11.w)),
              ],
            ),
          ),
          // _PostCaption: padding horizontal 12.w, vertical 2; Row: username + caption line + "more" (padding left 4.w)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: p, vertical: 2.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _box(64.w, 11.w),
                SizedBox(width: 4.w),
                Expanded(child: _box(double.infinity, 11.w)),
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: _box(28.w, 11.w),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _iconBox(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size / 5),
      ),
    );
  }
}
