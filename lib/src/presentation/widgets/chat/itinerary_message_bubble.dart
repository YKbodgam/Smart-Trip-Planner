import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../../domain/entities/itinerary.dart';

class ItineraryMessageBubble extends StatelessWidget {
  final Itinerary itinerary;
  final VoidCallback? onSaveOffline;
  final VoidCallback? onFollowUp;

  const ItineraryMessageBubble({
    super.key,
    required this.itinerary,
    this.onSaveOffline,
    this.onFollowUp,
  });

  Future<void> _openInMaps() async {
    // TODO: Open maps with itinerary locations
    const url = 'https://maps.google.com/?q=Mumbai+to+Bali';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

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
              child: Icon(
                Icons.smart_toy,
                color: AppColors.white,
                size: 16.w,
              ),
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
                    'Itinera AI',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Itinerary Content
                Container(
                  padding: EdgeInsets.all(ScreenUtilHelper.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.aiMessageBg,
                    borderRadius: BorderRadius.circular(ScreenUtilHelper.radius16),
                    border: Border.all(color: AppColors.outline.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day Summary
                      if (itinerary.days.isNotEmpty)
                        Text(
                          itinerary.days.first.summary,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      
                      SizedBox(height: ScreenUtilHelper.spacing16),
                      
                      // Activities List
                      if (itinerary.days.isNotEmpty)
                        ...itinerary.days.first.items.map((item) => Padding(
                          padding: EdgeInsets.only(bottom: ScreenUtilHelper.spacing8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 4.w,
                                height: 4.w,
                                margin: EdgeInsets.only(
                                  top: 8.h,
                                  right: ScreenUtilHelper.spacing8,
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
                      InkWell(
                        onTap: _openInMaps,
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
                      
                      SizedBox(height: ScreenUtilHelper.spacing8),
                      
                      // Location Info
                      Container(
                        padding: EdgeInsets.all(ScreenUtilHelper.spacing12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(ScreenUtilHelper.radius8),
                        ),
                        child: Text(
                          'Mumbai to Bali, Indonesia | 11hrs 5mins',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: ScreenUtilHelper.spacing12),
                
                // Action Buttons
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Copy itinerary
                      },
                      icon: Icon(
                        Icons.copy_outlined,
                        size: 16.w,
                        color: AppColors.onSurfaceVariant,
                      ),
                      label: Text(
                        'Copy',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    
                    TextButton.icon(
                      onPressed: onSaveOffline,
                      icon: Icon(
                        Icons.download_outlined,
                        size: 16.w,
                        color: AppColors.onSurfaceVariant,
                      ),
                      label: Text(
                        'Save Offline',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Regenerate itinerary
                      },
                      icon: Icon(
                        Icons.refresh_outlined,
                        size: 16.w,
                        color: AppColors.onSurfaceVariant,
                      ),
                      label: Text(
                        'Regenerate',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
