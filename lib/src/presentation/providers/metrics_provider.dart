import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/token_usage_service.dart';

// Provider for the token usage service
final tokenUsageServiceProvider = Provider<TokenUsageService>((ref) {
  return TokenUsageService();
});

// Provider for the metrics state
final metricsProvider = StateNotifierProvider<MetricsNotifier, MetricsState>((
  ref,
) {
  final tokenService = ref.watch(tokenUsageServiceProvider);
  return MetricsNotifier(tokenService);
});

class MetricsNotifier extends StateNotifier<MetricsState> {
  final TokenUsageService _tokenService;

  MetricsNotifier(this._tokenService) : super(const MetricsState.initial()) {
    _initializeService();
    _loadQuota();
  }

  Future<void> _initializeService() async {
    final result = await _tokenService.init();
    result.fold(
      (failure) => state = MetricsState.error(failure.message),
      (_) => _loadQuota(),
    );
  }

  Future<void> _loadQuota() async {
    state = const MetricsState.loading();

    final result = await _tokenService.getRemainingQuota();
    result.fold(
      (failure) => state = MetricsState.error(failure.message),
      (quota) => state = MetricsState.loaded(quota),
    );
  }

  Future<void> refreshMetrics() async {
    await _loadQuota();
  }

  Future<void> getDailyUsage(DateTime date) async {
    state = const MetricsState.loading();

    final result = await _tokenService.getDailyUsage(date);
    result.fold(
      (failure) => state = MetricsState.error(failure.message),
      (usage) => state = MetricsState.usageLoaded(usage),
    );
  }

  Future<void> getUsageHistory({int days = 7}) async {
    state = const MetricsState.loading();

    final result = await _tokenService.getUsageHistory(days: days);
    result.fold(
      (failure) => state = MetricsState.error(failure.message),
      (history) => state = MetricsState.historyLoaded(history),
    );
  }
}

class MetricsState {
  const MetricsState();

  const factory MetricsState.initial() = _Initial;
  const factory MetricsState.loading() = _Loading;
  const factory MetricsState.loaded(Map<String, dynamic> quota) = _Loaded;
  const factory MetricsState.usageLoaded(Map<String, dynamic> usage) =
      _UsageLoaded;
  const factory MetricsState.historyLoaded(List<Map<String, dynamic>> history) =
      _HistoryLoaded;
  const factory MetricsState.error(String message) = _Error;

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(Map<String, dynamic> quota)? loaded,
    T Function(Map<String, dynamic> usage)? usageLoaded,
    T Function(List<Map<String, dynamic>> history)? historyLoaded,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is _Initial && initial != null) {
      return initial();
    } else if (this is _Loading && loading != null) {
      return loading();
    } else if (this is _Loaded && loaded != null) {
      final s = this as _Loaded;
      return loaded(s.quota);
    } else if (this is _UsageLoaded && usageLoaded != null) {
      final s = this as _UsageLoaded;
      return usageLoaded(s.usage);
    } else if (this is _HistoryLoaded && historyLoaded != null) {
      final s = this as _HistoryLoaded;
      return historyLoaded(s.history);
    } else if (this is _Error && error != null) {
      final s = this as _Error;
      return error(s.message);
    }
    return orElse();
  }
}

class _Initial extends MetricsState {
  const _Initial();
}

class _Loading extends MetricsState {
  const _Loading();
}

class _Loaded extends MetricsState {
  final Map<String, dynamic> quota;
  const _Loaded(this.quota);
}

class _UsageLoaded extends MetricsState {
  final Map<String, dynamic> usage;
  const _UsageLoaded(this.usage);
}

class _HistoryLoaded extends MetricsState {
  final List<Map<String, dynamic>> history;
  const _HistoryLoaded(this.history);
}

class _Error extends MetricsState {
  final String message;
  const _Error(this.message);
}
