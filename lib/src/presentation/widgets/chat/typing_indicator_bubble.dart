import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';

class TypingIndicatorBubble extends StatefulWidget {
  final String partialText;

  const TypingIndicatorBubble({super.key, required this.partialText});

  @override
  State<TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
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
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtilHelper.spacing16,
                vertical: ScreenUtilHelper.spacing12,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(ScreenUtilHelper.radius16),
                  bottomLeft: Radius.circular(ScreenUtilHelper.radius16),
                  bottomRight: Radius.circular(ScreenUtilHelper.radius16),
                ),
                border: Border.all(color: AppColors.outline.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Partial text with animated cursor
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.partialText,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.onSurface),
                        ),
                        // Animated cursor
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: FadeTransition(
                            opacity: _animation,
                            child: Container(
                              width: 2,
                              height: 16,
                              color: AppColors.primary,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
