import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../common/send_button.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final VoidCallback? onVoiceInput;
  final bool enabled;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.onVoiceInput,
    this.enabled = true,
  });

  void _handleSend() {
    final message = controller.text.trim();
    if (message.isNotEmpty && enabled) {
      onSend(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtilHelper.spacing16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.outline.withOpacity(0.2), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Text Input Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.chatInputBg,
                  borderRadius: BorderRadius.circular(
                    ScreenUtilHelper.radius24,
                  ),
                  border: Border.all(color: AppColors.outline.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        enabled: enabled,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Follow up to refine',
                          hintStyle: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ScreenUtilHelper.spacing16,
                            vertical: ScreenUtilHelper.spacing12,
                          ),
                        ),
                        onSubmitted: enabled ? (value) => _handleSend() : null,
                      ),
                    ),

                    // Voice Input Button
                    if (onVoiceInput != null)
                      IconButton(
                        onPressed: enabled ? onVoiceInput : null,
                        icon: Icon(
                          Icons.mic,
                          color: enabled
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant.withOpacity(0.5),
                          size: 20.w,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(width: ScreenUtilHelper.spacing8),

            // Send Button
            SendButton(
              onPressed: _handleSend,
              enabled: enabled && controller.text.trim().isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }
}
