import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../providers/auth_provider.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback onProfileTap;

  const HomeAppBar({
    super.key,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );
    
    final name = user?.displayName ?? (user?.email.split('@').first ?? 'T');
    final avatarText = (name.isNotEmpty ? name[0] : 'T').toUpperCase();
    final avatarUrl = user?.photoUrl;

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Icon(
            Icons.home_outlined,
            color: AppColors.onBackground,
            size: 24.w,
          ),
          SizedBox(width: ScreenUtilHelper.spacing8),
          Text(
            'Home',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 40.w,
            height: 40.w,
            margin: EdgeInsets.only(right: ScreenUtilHelper.spacing16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildAvatarText(context, avatarText);
                      },
                    ),
                  )
                : _buildAvatarText(context, avatarText),
          ),
        ),
      ],
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

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
