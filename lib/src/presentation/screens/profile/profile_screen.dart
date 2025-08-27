import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/services/token_usage_provider.dart';
import '../../providers/auth_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/token_usage_card.dart';
import '../../widgets/common/custom_button.dart';

final metricsHudProvider = StateProvider<bool>((ref) => false);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    } else {
      final formatter = DateFormat('MMM d, h:mm a');
      return formatter.format(dateTime);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
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
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMetricsHud = ref.watch(metricsHudProvider);
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.bug_report,
              color: showMetricsHud
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            onPressed: () =>
                ref.read(metricsHudProvider.notifier).state = !showMetricsHud,
            tooltip: 'Toggle Metrics HUD',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtilHelper.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: ScreenUtilHelper.spacing24),
            const ProfileHeader(
              name: 'Shubham S.',
              email: 'shubham.s@gmail.com',
              avatarText: 'S',
            ),
            SizedBox(height: ScreenUtilHelper.spacing32),
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
            _buildSettingsSection(context),
            SizedBox(height: ScreenUtilHelper.spacing40),
            CustomButton(
              text: 'Log Out',
              type: ButtonType.outline,
              onPressed: () => _handleLogout(context),
              icon: Icons.logout,
            ),
            SizedBox(height: ScreenUtilHelper.spacing24),
            if (showMetricsHud)
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: ScreenUtilHelper.spacing16,
                ),
                padding: EdgeInsets.all(ScreenUtilHelper.spacing16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    ScreenUtilHelper.radius16,
                  ),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metrics HUD',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: ScreenUtilHelper.spacing8),
                    Consumer(
                      builder: (context, ref, _) {
                        final user = ref
                            .watch(authProvider)
                            .maybeWhen(
                              authenticated: (user) => user,
                              orElse: () => null,
                            );

                        if (user == null) {
                          return const SizedBox();
                        }

                        final tokenStats = ref.watch(tokenUsageStatsProvider);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Model: GPT-4o-mini'),
                            Text(
                              'Request Tokens: ${tokenStats.requestTokensUsed}/${tokenStats.requestTokensLimit}',
                            ),
                            Text(
                              'Response Tokens: ${tokenStats.responseTokensUsed}/${tokenStats.responseTokensLimit}',
                            ),
                            Text('Total Tokens: ${tokenStats.totalTokensUsed}'),
                            Text(
                              'Cost (USD): \$${tokenStats.totalCost.toStringAsFixed(3)}',
                            ),
                            Text(
                              'Last Updated: ${_formatDateTime(DateTime.now())}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
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
