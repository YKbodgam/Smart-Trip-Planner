import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/metrics_provider.dart';

class MetricsOverlay extends ConsumerWidget {
  final Widget child;
  final bool isEnabled;

  const MetricsOverlay({super.key, required this.child, this.isEnabled = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isEnabled) return child;

    final metricsState = ref.watch(metricsProvider);

    return Stack(
      children: [
        child,
        Positioned(
          bottom: 0,
          right: 0,
          child: metricsState.maybeWhen(
            loaded: (quota) => _buildMetricsCard(context, quota),
            loading: () => _buildLoadingIndicator(),
            error: (message) => _buildErrorBadge(context, message),
            orElse: () => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsCard(BuildContext context, Map<String, dynamic> quota) {
    final usedTokens = quota['usedTokens'] as int;
    final maxTokens = quota['maxTokens'] as int;
    final tokenPercentage = quota['tokenPercentage'] as double;
    final usedCost = quota['usedCost'] as double;
    final maxCost = quota['maxCost'] as double;

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'AI Usage Metrics',
            style: TextStyle(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          _buildProgressBar(
            'Tokens',
            usedTokens,
            maxTokens,
            tokenPercentage,
            AppColors.primary,
          ),
          const SizedBox(height: 4),
          _buildProgressBar(
            'Cost',
            usedCost,
            maxCost,
            (usedCost / maxCost) * 100,
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    String label,
    num used,
    num max,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: TextStyle(color: AppColors.onPrimary, fontSize: 9),
            ),
            Text(
              '$used / $max (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                color: AppColors.onPrimary,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 150,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorBadge(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.error_outline, color: Colors.white, size: 16),
    );
  }
}
