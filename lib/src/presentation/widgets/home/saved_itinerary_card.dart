import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';

class SavedItineraryCard extends StatelessWidget {
  final String title;
  final bool isOffline;
  final VoidCallback onTap;

  const SavedItineraryCard({
    super.key,
    required this.title,
    required this.isOffline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ScreenUtilHelper.radius12),
      child: Container(
        padding: EdgeInsets.all(ScreenUtilHelper.spacing16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(ScreenUtilHelper.radius12),
          border: Border.all(
            color: AppColors.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Offline Indicator
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: isOffline ? AppColors.success : AppColors.grey400,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            
            SizedBox(width: ScreenUtilHelper.spacing12),
            
            // Title
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Arrow Icon
            Icon(
              Icons.chevron_right,
              color: AppColors.onSurfaceVariant,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}
