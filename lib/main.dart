import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/feed_provider.dart';
import 'screens/home/view/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  /// Design size used for responsive scaling (e.g. iPhone 11 Pro / common mockup).
  static const Size _designSize = Size(375, 812);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: _designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<FeedProvider>(
              create: (_) => FeedProvider()..loadFeed(),
            ),
          ],
          child: MaterialApp(
            title: 'Instagram',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme.copyWith(
              textTheme: GoogleFonts.getTextTheme(
                'Lato',
                AppTheme.darkTheme.textTheme,
              ),
            ),
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
}
