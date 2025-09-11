import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../common/user_avatar.dart';
import '../common/feedback_widgets.dart';

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
          const AIAvatar(size: 32),
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

                // Error Display
                ErrorDisplay(
                  message: message,
                  onRetry: onRegenerate,
                  compact: true,
                  icon: Icons.warning_amber_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
