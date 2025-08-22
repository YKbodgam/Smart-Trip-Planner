import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/token_usage_card.dart';
import '../../widgets/common/custom_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
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
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      // TODO: Implement logout logic
      // Clear user data, tokens, etc.
      context.go('/login');
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtilHelper.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: ScreenUtilHelper.spacing24),
            
            // Profile Header
            const ProfileHeader(
              name: 'Shubham S.',
              email: 'shubham.s@gmail.com',
              avatarText: 'S',
            ),
            
            SizedBox(height: ScreenUtilHelper.spacing32),
            
            // Token Usage Cards
            TokenUsageCard(
              title: 'Request Tokens',
              used: 100,
              total: 1000,
              color: AppColors.primary,
            ),
            
            SizedBox(height: ScreenUtilHelper.spacing16),
            
            TokenUsageCard(
              title: 'Response Tokens',
              used: 75,
              total: 1000,
              color: AppColors.error,
            ),
            
            SizedBox(height: ScreenUtilHelper.spacing16),
            
            // Total Cost Card
            Container(
              padding: EdgeInsets.all(ScreenUtilHelper.spacing20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(ScreenUtilHelper.radius16),
                border: Border.all(color: AppColors.outline.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Cost',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '\$0.07 USD',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: ScreenUtilHelper.spacing40),
            
            // Settings Section (Future Enhancement)
            _buildSettingsSection(context),
            
            SizedBox(height: ScreenUtilHelper.spacing40),
            
            // Logout Button
            CustomButton(
              text: 'Log Out',
              type: ButtonType.outline,
              onPressed: () => _handleLogout(context),
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
        
        // Settings Items
        _buildSettingsItem(
          context,
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage your notification preferences',
          onTap: () {
            // TODO: Navigate to notifications settings
          },
        ),
        
        _buildSettingsItem(
          context,
          icon: Icons.language_outlined,
          title: 'Language',
          subtitle: 'English',
          onTap: () {
            // TODO: Navigate to language settings
          },
        ),
        
        _buildSettingsItem(
          context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {
            // TODO: Navigate to help & support
          },
        ),
        
        _buildSettingsItem(
          context,
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App version and information',
          onTap: () {
            // TODO: Navigate to about page
          },
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
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20.w,
              ),
            ),
            
            SizedBox(width: ScreenUtilHelper.spacing16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
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
              Icons.chevron_right,
              color: AppColors.onSurfaceVariant,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}
