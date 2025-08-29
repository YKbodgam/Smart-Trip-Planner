import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';

class ErrorMessageBubble extends StatelessWidget {
  final String message;
  final VoidCallback? onRegenerate;

  const ErrorMessageBubble({
    super.key,
    required this.message,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtilHelper.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Icon(Icons.smart_toy, color: AppColors.white, size: 16.w),
            ),
          ),

          SizedBox(width: ScreenUtilHelper.spacing8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Label
                Padding(
                  padding: EdgeInsets.only(bottom: ScreenUtilHelper.spacing4),
                  child: Text(
                    'Itinerary AI',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Error Bubble
                Container(
                  padding: EdgeInsets.all(ScreenUtilHelper.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      ScreenUtilHelper.radius16,
                    ),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error Icon and Message
                      Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),

                          SizedBox(width: ScreenUtilHelper.spacing8),

                          Expanded(
                            child: Text(
                              message,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),

                      if (onRegenerate != null) ...[
                        SizedBox(height: ScreenUtilHelper.spacing12),

                        // Regenerate Button
                        TextButton.icon(
                          onPressed: onRegenerate,
                          icon: Icon(
                            Icons.refresh,
                            size: 16.w,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Regenerate',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.primary),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtilHelper.spacing8,
                              vertical: ScreenUtilHelper.spacing4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
