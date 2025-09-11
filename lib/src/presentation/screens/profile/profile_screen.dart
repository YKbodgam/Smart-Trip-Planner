import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/common/custom_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await ref.read(authProvider.notifier).signOut();
      // Navigation will be handled automatically by the router
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtilHelper.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: ScreenUtilHelper.spacing24),
            Consumer(
              builder: (context, ref, _) {
                final user = ref
                    .watch(authProvider)
                    .maybeWhen(
                      authenticated: (user) => user,
                      orElse: () => null,
                    );
                final name =
                    user?.displayName ??
                    (user?.email.split('@').first ?? 'Traveler');
                final email = user?.email ?? '';
                final avatarText = (name.isNotEmpty ? name[0] : 'T')
                    .toUpperCase();
                return ProfileHeader(
                  name: name,
                  email: email,
                  avatarText: avatarText,
                  avatarUrl: user?.photoUrl,
                );
              },
            ),
            SizedBox(height: ScreenUtilHelper.spacing32),
            _buildSettingsSection(context),
            SizedBox(height: ScreenUtilHelper.spacing40),
            CustomButton(
              text: 'Log Out',
              type: ButtonType.outline,
              onPressed: () => _handleLogout(context, ref),
              icon: Icons.logout,
            ),
            SizedBox(height: ScreenUtilHelper.spacing24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ScreenUtilHelper.spacing16),
        _buildSettingsItem(
          context,
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage your notification preferences',
          onTap: () {},
        ),
        _buildSettingsItem(
          context,
          icon: Icons.language_outlined,
          title: 'Language',
          subtitle: 'English',
          onTap: () {},
        ),
        _buildSettingsItem(
          context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {},
        ),
        _buildSettingsItem(
          context,
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App version and information',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ScreenUtilHelper.radius12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtilHelper.spacing12,
          horizontal: ScreenUtilHelper.spacing4,
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ScreenUtilHelper.radius8),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            SizedBox(width: ScreenUtilHelper.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: ScreenUtilHelper.spacing4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
