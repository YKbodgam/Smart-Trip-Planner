import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'src/app/routes/app_pages.dart';
import 'src/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Initialize controller
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(390, 844), // iPhone 12 base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => MaterialApp(
        title: "Peece",
        locale: Locale('en', 'US'),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightThemeData,
        themeMode: ThemeMode.light,
        initialRoute: Routes.SPLASH,
      ),
    );
  }
}
