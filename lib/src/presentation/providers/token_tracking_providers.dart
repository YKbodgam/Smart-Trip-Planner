import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/token_tracking_service.dart';

// Token tracking service singleton provider
final tokenTrackingServiceProvider = Provider<TokenTrackingService>((ref) {
  return TokenTrackingService.instance;
});

// Live token usage stats provider
final tokenUsageStatsProvider =
    StateNotifierProvider<TokenUsageNotifier, TokenUsageStats>((ref) {
      final service = ref.watch(tokenTrackingServiceProvider);
      return TokenUsageNotifier(service);
    });

class TokenUsageNotifier extends StateNotifier<TokenUsageStats> {
  final TokenTrackingService _service;

  TokenUsageNotifier(this._service)
    : super(
        const TokenUsageStats(
          requestTokensUsed: 0,
          responseTokensUsed: 0,
          totalTokensUsed: 0,
          totalCost: 0.0,
          requestTokensLimit: 4000, // Conservative limits for gpt-4
          responseTokensLimit: 8000,
          costLimit: 1.0, // $1.00 per session
        ),
      ) {
    // Listen to token usage events
    _service.usageStream.listen((record) {
      state = TokenUsageStats(
        requestTokensUsed: state.requestTokensUsed + record.promptTokens,
        responseTokensUsed: state.responseTokensUsed + record.completionTokens,
        totalTokensUsed:
            state.totalTokensUsed +
            record.promptTokens +
            record.completionTokens,
        totalCost: state.totalCost + record.cost,
        requestTokensLimit: state.requestTokensLimit,
        responseTokensLimit: state.responseTokensLimit,
        costLimit: state.costLimit,
      );
    });
  }
}
