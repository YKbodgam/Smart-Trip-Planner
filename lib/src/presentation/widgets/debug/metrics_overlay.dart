import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/screen_util_helper.dart';
import '../../providers/token_tracking_providers.dart';

class MetricsOverlay extends ConsumerWidget {
  const MetricsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(tokenUsageStatsProvider);

    return Positioned(
      right: 8,
      bottom: 8,
      child: Container(
        padding: EdgeInsets.all(ScreenUtilHelper.spacing12),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(ScreenUtilHelper.radius12),
          border: Border.all(color: AppColors.outline.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey900.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Token Usage',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: 4),
            _buildProgressBar(
              context: context,
              label: 'Prompt',
              used: stats.requestTokensUsed,
              total: stats.requestTokensLimit,
              percentage: stats.requestTokensPercentage,
            ),
            const SizedBox(height: 2),
            _buildProgressBar(
              context: context,
              label: 'Response',
              used: stats.responseTokensUsed,
              total: stats.responseTokensLimit,
              percentage: stats.responseTokensPercentage,
            ),
            const SizedBox(height: 4),
            Text(
              'Cost: \$${stats.totalCost.toStringAsFixed(3)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required BuildContext context,
    required String label,
    required int used,
    required int total,
    required double percentage,
  }) {
    final isNearLimit = percentage > 0.8;
    final isOverLimit = percentage >= 1.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            '$label: $used/$total',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverLimit
                    ? AppColors.error
                    : isNearLimit
                    ? AppColors.warning
                    : AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
