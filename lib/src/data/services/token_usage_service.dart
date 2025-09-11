import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';

import '../../core/error/failures.dart';
import '../../core/config/app_environment.dart';

class TokenUsageService {
  static const String _tokenUsageBoxName = 'token_usage';

  // Groq token pricing (as of 2023)
  static const double _groqTokenPricePer1M = 1.5; // $1.50 per million tokens

  late final Box<Map> _tokenUsageBox;
  bool _isInitialized = false;

  // Singleton instance
  static final TokenUsageService _instance = TokenUsageService._internal();
  factory TokenUsageService() => _instance;
  TokenUsageService._internal();

  Future<Either<Failure, void>> init() async {
    if (_isInitialized) return const Right(null);

    try {
      // Initialize Hive box for token usage
      _tokenUsageBox = await Hive.openBox<Map>(_tokenUsageBoxName);
      _isInitialized = true;
      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Failed to initialize token usage tracking: $e',
        ),
      );
    }
  }

  Future<Either<Failure, void>> trackUsage({
    required int promptTokens,
    required int completionTokens,
    required String model,
    String? conversationId,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final today = _getDateKey(DateTime.now());
      final totalTokens = promptTokens + completionTokens;
      final estimatedCost = _calculateCost(promptTokens, completionTokens);

      // Get current usage for today
      final Map<dynamic, dynamic> dailyUsage = _tokenUsageBox.get(today) ?? {};

      // Update usage
      dailyUsage['date'] = today;
      dailyUsage['promptTokens'] =
          (dailyUsage['promptTokens'] as int? ?? 0) + promptTokens;
      dailyUsage['completionTokens'] =
          (dailyUsage['completionTokens'] as int? ?? 0) + completionTokens;
      dailyUsage['totalTokens'] =
          (dailyUsage['totalTokens'] as int? ?? 0) + totalTokens;
      dailyUsage['cost'] =
          (dailyUsage['cost'] as double? ?? 0.0) + estimatedCost;
      dailyUsage['requestCount'] =
          (dailyUsage['requestCount'] as int? ?? 0) + 1;

      // Store conversations if ID provided
      if (conversationId != null) {
        final conversations =
            dailyUsage['conversations'] as Map<dynamic, dynamic>? ?? {};
        final conversationUsage =
            conversations[conversationId] as Map<dynamic, dynamic>? ?? {};

        conversationUsage['promptTokens'] =
            (conversationUsage['promptTokens'] as int? ?? 0) + promptTokens;
        conversationUsage['completionTokens'] =
            (conversationUsage['completionTokens'] as int? ?? 0) +
            completionTokens;
        conversationUsage['totalTokens'] =
            (conversationUsage['totalTokens'] as int? ?? 0) + totalTokens;
        conversationUsage['cost'] =
            (conversationUsage['cost'] as double? ?? 0.0) + estimatedCost;

        conversations[conversationId] = conversationUsage;
        dailyUsage['conversations'] = conversations;
      }

      // Save updated usage
      await _tokenUsageBox.put(today, Map<dynamic, dynamic>.from(dailyUsage));

      // Check if daily limit is exceeded
      final dailyTotalTokens = dailyUsage['totalTokens'] as int;
      final dailyTotalCost = dailyUsage['cost'] as double;

      if (dailyTotalTokens > AppEnvironmentConfig.maxTokensPerDay) {
        return Left(
          TokenLimitFailure(
            message: 'Daily token limit exceeded',
            details:
                'Used $dailyTotalTokens out of ${AppEnvironmentConfig.maxTokensPerDay} allowed tokens',
          ),
        );
      }

      if (dailyTotalCost > AppEnvironmentConfig.maxCostPerDay) {
        return Left(
          TokenLimitFailure(
            message: 'Daily cost limit exceeded',
            details:
                'Used \$$dailyTotalCost out of \$${AppEnvironmentConfig.maxCostPerDay} allowed',
          ),
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to track token usage: $e'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getDailyUsage(
    DateTime date,
  ) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final dateKey = _getDateKey(date);
      final Map<dynamic, dynamic>? usage = _tokenUsageBox.get(dateKey);

      if (usage == null) {
        return Right({
          'date': dateKey,
          'promptTokens': 0,
          'completionTokens': 0,
          'totalTokens': 0,
          'cost': 0.0,
          'requestCount': 0,
          'conversations': {},
        });
      }

      return Right(Map<String, dynamic>.from(usage));
    } catch (e) {
      return Left(
        DatabaseFailure(message: 'Failed to retrieve token usage: $e'),
      );
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getUsageHistory({
    int days = 7,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final history = <Map<String, dynamic>>[];
      final today = DateTime.now();

      for (int i = 0; i < days; i++) {
        final date = today.subtract(Duration(days: i));
        final dateKey = _getDateKey(date);
        final Map<dynamic, dynamic>? usage = _tokenUsageBox.get(dateKey);

        if (usage != null) {
          history.add(Map<String, dynamic>.from(usage));
        } else {
          history.add({
            'date': dateKey,
            'promptTokens': 0,
            'completionTokens': 0,
            'totalTokens': 0,
            'cost': 0.0,
            'requestCount': 0,
          });
        }
      }

      return Right(history);
    } catch (e) {
      return Left(
        DatabaseFailure(message: 'Failed to retrieve usage history: $e'),
      );
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getTotalUsage() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      int totalPromptTokens = 0;
      int totalCompletionTokens = 0;
      int totalRequests = 0;
      double totalCost = 0.0;

      final allKeys = _tokenUsageBox.keys;

      for (final key in allKeys) {
        final Map<dynamic, dynamic>? usage = _tokenUsageBox.get(key);

        if (usage != null) {
          totalPromptTokens += (usage['promptTokens'] as int?) ?? 0;
          totalCompletionTokens += (usage['completionTokens'] as int?) ?? 0;
          totalRequests += (usage['requestCount'] as int?) ?? 0;
          totalCost += (usage['cost'] as double?) ?? 0.0;
        }
      }

      return Right({
        'promptTokens': totalPromptTokens,
        'completionTokens': totalCompletionTokens,
        'totalTokens': totalPromptTokens + totalCompletionTokens,
        'cost': totalCost,
        'requestCount': totalRequests,
      });
    } catch (e) {
      return Left(
        DatabaseFailure(message: 'Failed to calculate total usage: $e'),
      );
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getRemainingQuota() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final today = _getDateKey(DateTime.now());
      final Map<dynamic, dynamic>? dailyUsage = _tokenUsageBox.get(today);

      final usedTokens = (dailyUsage?['totalTokens'] as int?) ?? 0;
      final usedCost = (dailyUsage?['cost'] as double?) ?? 0.0;

      final remainingTokens = AppEnvironmentConfig.maxTokensPerDay - usedTokens;
      final remainingCost = AppEnvironmentConfig.maxCostPerDay - usedCost;

      final tokenPercentage =
          (usedTokens / AppEnvironmentConfig.maxTokensPerDay) * 100;
      final costPercentage =
          (usedCost / AppEnvironmentConfig.maxCostPerDay) * 100;

      return Right({
        'usedTokens': usedTokens,
        'maxTokens': AppEnvironmentConfig.maxTokensPerDay,
        'remainingTokens': remainingTokens,
        'tokenPercentage': tokenPercentage,

        'usedCost': usedCost,
        'maxCost': AppEnvironmentConfig.maxCostPerDay,
        'remainingCost': remainingCost,
        'costPercentage': costPercentage,

        'isTokenLimitExceeded':
            usedTokens >= AppEnvironmentConfig.maxTokensPerDay,
        'isCostLimitExceeded': usedCost >= AppEnvironmentConfig.maxCostPerDay,
      });
    } catch (e) {
      return Left(
        DatabaseFailure(message: 'Failed to calculate remaining quota: $e'),
      );
    }
  }

  // Helper methods
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  double _calculateCost(int promptTokens, int completionTokens) {
    final totalTokens = promptTokens + completionTokens;
    return (totalTokens / 1000000) * _groqTokenPricePer1M;
  }
}
