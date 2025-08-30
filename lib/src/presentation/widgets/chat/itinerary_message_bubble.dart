import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../../domain/entities/itinerary.dart';
import '../../../data/services/web_search_service.dart';

class GoogleSearchResultsBubble extends StatelessWidget {
  final List<SearchResult> results;
  const GoogleSearchResultsBubble({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.search, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Google Search Results',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                ...results.map((result) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final url = Uri.parse(result.url);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            },
                            child: Text(
                              result.title,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result.snippet,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            result.displayLink,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ItineraryMessageBubble extends StatelessWidget {
  final Itinerary? previousItinerary;
  final Itinerary itinerary;
  final VoidCallback? onSaveOffline;
  final VoidCallback? onFollowUp;

  const ItineraryMessageBubble({
    super.key,
    required this.itinerary,
    this.previousItinerary,
    this.onSaveOffline,
    this.onFollowUp,
  });

  Future<void> _openInMaps() async {
    // Extract first location from itinerary
    final firstDay = itinerary.days.first;
    final firstLocation = firstDay.items.firstWhere(
      (item) => item.location != null,
      orElse: () => firstDay.items.first,
    );

    final query = firstLocation.location ?? firstLocation.activity;
    final url = 'https://maps.google.com/?q=${Uri.encodeComponent(query)}';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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

                // Itinerary Content
                Container(
                  padding: EdgeInsets.all(ScreenUtilHelper.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.aiMessageBg,
                    borderRadius: BorderRadius.circular(
                      ScreenUtilHelper.radius16,
                    ),
                    border: Border.all(
                      color: AppColors.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day Summary
                      if (itinerary.days.isNotEmpty)
                        Text(
                          itinerary.days.first.summary,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                        ),

                      SizedBox(height: ScreenUtilHelper.spacing16),

                      // Activities List with diff/highlight
                      if (itinerary.days.isNotEmpty)
                        ...List.generate(itinerary.days.length, (dayIdx) {
                          final day = itinerary.days[dayIdx];
                          final prevDay =
                              previousItinerary != null &&
                                  previousItinerary!.days.length > dayIdx
                              ? previousItinerary!.days[dayIdx]
                              : null;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Day ${dayIdx + 1}: ${day.summary}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              ...day.items.map((item) {
                                final isNew =
                                    prevDay == null ||
                                    !prevDay.items.any(
                                      (prevItem) =>
                                          prevItem.activity == item.activity &&
                                          prevItem.time == item.time,
                                    );
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: ScreenUtilHelper.spacing8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 4.w,
                                        height: 4.w,
                                        margin: EdgeInsets.only(
                                          top: 8.h,
                                          right: ScreenUtilHelper.spacing8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isNew
                                              ? AppColors.success
                                              : AppColors.onSurface,
                                          borderRadius: BorderRadius.circular(
                                            2.r,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: isNew
                                                      ? AppColors.success
                                                      : AppColors.onSurface,
                                                ),
                                            children: [
                                              if (isNew)
                                                WidgetSpan(
                                                  child: Icon(
                                                    Icons.fiber_new,
                                                    color: AppColors.success,
                                                    size: 16.w,
                                                  ),
                                                ),
                                              TextSpan(
                                                text: '${item.time}: ',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(text: item.activity),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          );
                        }),

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
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
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
                          borderRadius: BorderRadius.circular(
                            ScreenUtilHelper.radius8,
                          ),
                        ),
                        child: Text(
                          'Mumbai to Bali, Indonesia | 11hrs 5mins',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.onSurfaceVariant),
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
                        final text = itinerary.days
                            .map((day) {
                              final activities = day.items
                                  .map((item) {
                                    return '${item.time}: ${item.activity}';
                                  })
                                  .join('\n');
                              return 'Day ${itinerary.days.indexOf(day) + 1}: ${day.summary}\n$activities';
                            })
                            .join('\n\n');

                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Itinerary copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
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
