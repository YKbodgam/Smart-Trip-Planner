import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

/// A reusable send button component for use in chat and other input fields
class SendButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool enabled;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final IconData icon;

  const SendButton({
    super.key,
    this.onPressed,
    this.enabled = true,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
    this.icon = Icons.send,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (enabled ? AppColors.primary : AppColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(size.r / 2),
      ),
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(
          icon,
          color: iconColor ?? AppColors.onPrimary,
          size: size.w * 0.45,
        ),
      ),
    );
  }
}
