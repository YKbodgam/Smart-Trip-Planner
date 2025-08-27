import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/token_tracking_service.dart';

final tokenTrackingServiceProvider = Provider<TokenTrackingService>((ref) {
  return TokenTrackingService();
});

final tokenUsageProvider = FutureProvider.family<TokenUsageStats, String>((
  ref,
  userId,
) async {
  final tokenService = ref.read(tokenTrackingServiceProvider);
  final result = await tokenService.getUserTokenUsage(userId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
});

final usageHistoryProvider =
    FutureProvider.family<List<TokenUsageRecord>, String>((ref, userId) async {
      final tokenService = ref.read(tokenTrackingServiceProvider);
      final result = await tokenService.getUserUsageHistory(
        userId: userId,
        limit: 10,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (records) => records,
      );
    });
