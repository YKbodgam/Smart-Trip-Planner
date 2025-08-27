import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'src/core/theme/app_theme.dart';
import 'src/core/router/app_router.dart';
import 'src/core/utils/screen_util_helper.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: ScreenUtilHelper.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp.router(
          title: 'Pathoria',
          debugShowMaterialGrid: false,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: router,
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();

            return child;
          },
        );
      },
    );
  }
}
