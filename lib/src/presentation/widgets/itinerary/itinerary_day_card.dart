import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../../domain/entities/itinerary.dart';

class ItineraryDayCard extends StatelessWidget {
  final ItineraryDay day;
  final VoidCallback? onOpenMaps;

  const ItineraryDayCard({
    super.key,
    required this.day,
    this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtilHelper.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(ScreenUtilHelper.radius16),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Summary
          Text(
            day.summary,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: ScreenUtilHelper.spacing16),
          
          // Activities List
          ...day.items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: ScreenUtilHelper.spacing12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4.w,
                  height: 4.w,
                  margin: EdgeInsets.only(
                    top: 8.h,
                    right: ScreenUtilHelper.spacing12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.onSurface,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: '${item.time}: ',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: item.activity),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
          
          SizedBox(height: ScreenUtilHelper.spacing16),
          
          // Maps Link
          if (onOpenMaps != null)
            InkWell(
              onTap: onOpenMaps,
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 16.w,
                  ),
                  SizedBox(width: ScreenUtilHelper.spacing4),
                  Text(
                    'Open in maps',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(width: ScreenUtilHelper.spacing4),
                  Icon(
                    Icons.open_in_new,
                    color: AppColors.primary,
                    size: 12.w,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
