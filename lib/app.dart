import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'src/core/theme/app_theme.dart';
import 'src/core/config/app_config.dart';
import 'src/core/router/app_router.dart';
import 'src/core/config/app_environment.dart';
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
          title: AppConfig.appName,
          debugShowMaterialGrid: false,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: router,
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();

            // ✅ Show environment badge only in debug or non-production env
            return AppConfig.environment != AppEnvironment.production
                ? Stack(
                    children: [
                      child,
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        right: 10,
                        child: EnvironmentBadge(
                          environment: AppConfig.environment,
                        ),
                      ),
                    ],
                  )
                : child;
          },
        );
      },
    );
  }
}

/// ✅ Extracted badge widget
class EnvironmentBadge extends StatelessWidget {
  final AppEnvironment environment;
  const EnvironmentBadge({super.key, required this.environment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: environment.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        environment.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// ✅ Extension for cleaner env → color mapping
extension AppEnvironmentX on AppEnvironment {
  Color get color {
    switch (this) {
      case AppEnvironment.development:
        return Colors.green;
      case AppEnvironment.staging:
        return Colors.orange;
      case AppEnvironment.production:
        return Colors.red;
    }
  }
}
