import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class UserAvatar extends ConsumerWidget {
  final double size;
  final String? overrideAvatarText;
  final String? overrideAvatarUrl;

  const UserAvatar({
    super.key,
    this.size = 40,
    this.overrideAvatarText,
    this.overrideAvatarUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref
        .watch(authProvider)
        .maybeWhen(authenticated: (user) => user, orElse: () => null);

    final name =
        overrideAvatarText ??
        user?.displayName ??
        (user?.email.split('@').first ?? 'T');

    final avatarText = (name.isNotEmpty ? name[0] : 'T').toUpperCase();
    final avatarUrl = overrideAvatarUrl ?? user?.photoUrl;

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size.r / 2),
      ),
      child: avatarUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(size.r / 2),
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAvatarText(context, avatarText);
                },
              ),
            )
          : _buildAvatarText(context, avatarText),
    );
  }

  Widget _buildAvatarText(BuildContext context, String text) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AIAvatar extends StatelessWidget {
  final double size;

  const AIAvatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(size.r / 2),
      ),
      child: Center(
        child: Icon(Icons.smart_toy, color: AppColors.white, size: size.w / 2),
      ),
    );
  }
}
