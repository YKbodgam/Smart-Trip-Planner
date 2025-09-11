import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';

/// Standardized error display widget for consistent error UI across the app
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final bool compact;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: EdgeInsets.all(ScreenUtilHelper.spacing12),
        decoration: BoxDecoration(
          color: AppColors.errorContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(ScreenUtilHelper.radius12),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.error, size: 20.w),
            SizedBox(width: ScreenUtilHelper.spacing8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(width: ScreenUtilHelper.spacing8),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Retry',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtilHelper.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.error, size: 48.w),
            SizedBox(height: ScreenUtilHelper.spacing16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.onSurface),
            ),
            if (onRetry != null) ...[
              SizedBox(height: ScreenUtilHelper.spacing24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onError,
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtilHelper.spacing24,
                    vertical: ScreenUtilHelper.spacing12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ScreenUtilHelper.radius8,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading indicator with optional text message
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool overlay;

  const LoadingIndicator({super.key, this.message, this.overlay = false});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        if (message != null) ...[
          SizedBox(height: ScreenUtilHelper.spacing16),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
          ),
        ],
      ],
    );

    if (overlay) {
      return Container(
        color: AppColors.background.withOpacity(0.7),
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}
