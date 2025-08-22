import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../../domain/entities/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtilHelper.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
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
          ],
          
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                // Sender Label
                if (!message.isUser)
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
                
                if (message.isUser)
                  Padding(
                    padding: EdgeInsets.only(bottom: ScreenUtilHelper.spacing4),
                    child: Text(
                      'You',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                
                // Message Bubble
                Container(
                  padding: EdgeInsets.all(ScreenUtilHelper.spacing16),
                  decoration: BoxDecoration(
                    color: message.isUser 
                        ? AppColors.userMessageBg 
                        : AppColors.aiMessageBg,
                    borderRadius: BorderRadius.circular(ScreenUtilHelper.radius16),
                    border: message.isUser 
                        ? null 
                        : Border.all(color: AppColors.outline.withOpacity(0.2)),
                  ),
                  child: Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                
                // Copy Button for user messages
                if (message.isUser)
                  Padding(
                    padding: EdgeInsets.only(top: ScreenUtilHelper.spacing8),
                    child: TextButton.icon(
                      onPressed: () {
                        // TODO: Copy message to clipboard
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
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtilHelper.spacing8,
                          vertical: ScreenUtilHelper.spacing4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          if (message.isUser) ...[
            SizedBox(width: ScreenUtilHelper.spacing8),
            // User Avatar
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Text(
                  'S',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
