import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';

class LoadingMessageBubble extends StatefulWidget {
  final String message;

  const LoadingMessageBubble({super.key, required this.message});

  @override
  State<LoadingMessageBubble> createState() => _LoadingMessageBubbleState();
}

class _LoadingMessageBubbleState extends State<LoadingMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

                // Loading Bubble
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
                  child: Row(
                    children: [
                      // Loading Indicator
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: AppColors.info,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),

                      SizedBox(width: ScreenUtilHelper.spacing8),

                      // Loading Text
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Text(
                            widget.message,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.onSurface.withOpacity(
                                    0.7 + 0.3 * _animation.value,
                                  ),
                                ),
                          );
                        },
                      ),
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
