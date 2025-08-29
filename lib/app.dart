import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'src/core/theme/app_theme.dart';
import 'src/core/router/app_router.dart';
import 'src/core/utils/screen_util_helper.dart';
import 'src/presentation/widgets/debug/metrics_overlay.dart';
import 'src/presentation/providers/metrics_providers.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: ScreenUtilHelper.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) {
        return MaterialApp.router(
          title: 'Itinerary AI',
          debugShowMaterialGrid: false,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: router,
          builder: (context, child) {
            // Add metrics overlay if enabled
            return Stack(
              children: [
                child ?? const SizedBox.shrink(),
                if (ref.watch(metricsVisibilityProvider))
                  const MetricsOverlay(),
              ],
            );
          },
        );
      },
    );
  }
}
