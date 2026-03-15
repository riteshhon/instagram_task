import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Instagram-style dark theme and responsive layout values.
class AppTheme {
  AppTheme._();

  static const Color primaryDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF0D0D0D);
  static const Color cardDark = Color(0xFF1C1C1E);
  static const Color dividerDark = Color(0xFF2C2C2E);
  static const Color onSurfaceDark = Color(0xFFF5F5F7);
  static const Color onSurfaceVariant = Color(0xFF8E8E93);
  static const Color verifiedBlue = Color(0xFF3797F0);
  static const Color accentRed = Color(0xFFED4956);
  static const Color storyGradientStart = Color(0xFFF58529);
  static const Color storyGradientMid = Color(0xFFDD2A7B);
  static const Color storyGradientEnd = Color(0xFF8134AF);
  static const Color storyGradientGreen = Color(0xFF515BD4);
  static const Color hashtagPurple = Color(0xFFB39DDB);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: ColorScheme.dark(
        surface: surfaceDark,
        onSurface: onSurfaceDark,
        primary: verifiedBlue,
        onPrimary: Colors.white,
        error: accentRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: onSurfaceDark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryDark,
        selectedItemColor: onSurfaceDark,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      iconTheme: const IconThemeData(color: onSurfaceDark, size: 28),
      textTheme: _textTheme,
    );
  }

  static TextTheme get _textTheme {
    const base = TextTheme(
      bodyLarge: TextStyle(color: onSurfaceDark, fontSize: 16),
      bodyMedium: TextStyle(color: onSurfaceDark, fontSize: 14),
      bodySmall: TextStyle(color: onSurfaceVariant, fontSize: 12),
      labelLarge: TextStyle(color: onSurfaceDark, fontSize: 14),
      labelMedium: TextStyle(color: onSurfaceVariant, fontSize: 12),
      titleMedium: TextStyle(color: onSurfaceDark, fontSize: 14, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: onSurfaceDark, fontSize: 12),
    );
    return base;
  }
}

/// Breakpoints for responsive layout (logical pixels).
class Breakpoints {
  static const double small = 360;
  static const double medium = 400;
  static const double large = 600;
  static const double tablet = 840;
}

/// Responsive layout helpers using ScreenUtil (design size 375x812).
/// All values scale from the design size; use after [ScreenUtilInit] in main.dart.
class Responsive {
  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;
  static EdgeInsets padding(BuildContext context) => MediaQuery.paddingOf(context);
  static double textScaleFactor(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1.0);

  static bool isSmall(BuildContext context) => width(context) < Breakpoints.small;
  static bool isMediumOrLarger(BuildContext context) =>
      width(context) >= Breakpoints.medium;
  static bool isLargeOrLarger(BuildContext context) =>
      width(context) >= Breakpoints.large;
  static bool isTablet(BuildContext context) =>
      width(context) >= Breakpoints.tablet;

  /// Scale by design width (ScreenUtil .w).
  static double scale(BuildContext context, double base) => base.w;

  /// Responsive font size (ScreenUtil .sp – adapts to screen and text scale).
  static double fontSize(BuildContext context, double base) => base.sp;

  /// Responsive spacing – width-based (ScreenUtil .w).
  static double spacing(BuildContext context, double base) => base.w;

  /// Responsive icon size (ScreenUtil .w).
  static double iconSize(BuildContext context, double base) => base.w;

  /// Story circle size – scales with design width.
  static double storySize(BuildContext context) => 68.w;

  /// Horizontal padding for content (ScreenUtil .w).
  static double horizontalPadding(BuildContext context) => 12.w;

  /// Vertical padding for sections.
  static double verticalPadding(BuildContext context) => 12.w;

  /// App bar height including safe area.
  static double appBarHeight(BuildContext context) =>
      44.w + padding(context).top;

  /// Bottom nav bar height (excluding safe area).
  static double bottomNavBarHeight(BuildContext context) => 56.w;

  /// Bottom nav total height including safe area.
  static double bottomNavHeight(BuildContext context) =>
      bottomNavBarHeight(context) + padding(context).bottom;

  /// Max content width for tablets (center content on large screens).
  static double? maxContentWidth(BuildContext context) {
    if (!isTablet(context)) return null;
    return Breakpoints.large;
  }

  /// Bottom sheet height as fraction of screen (responsive).
  static double bottomSheetHeightFraction(BuildContext context) {
    if (height(context) < 600) return 0.9;
    return 0.85;
  }
}
