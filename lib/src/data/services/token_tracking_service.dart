import 'dart:async';
import 'package:dartz/dartz.dart';

import '../../core/database/hive_service.dart';
import '../../core/error/failures.dart';

class TokenTrackingService {
  static final TokenTrackingService _instance =
      TokenTrackingService._internal();
  static TokenTrackingService get instance => _instance;

  final HiveService _hiveService;
  final _controller = StreamController<TokenUsageRecord>.broadcast();
  Stream<TokenUsageRecord> get usageStream => _controller.stream;

  // OpenAI pricing (as of 2024) - prices per 1K tokens
  static const double _gpt4oMiniInputPrice = 0.00015; // $0.15 per 1M tokens
  static const double _gpt4oMiniOutputPrice = 0.0006; // $0.60 per 1M tokens
  static const double _gpt4InputPrice = 0.03; // $30 per 1M tokens
  static const double _gpt4OutputPrice = 0.06; // $60 per 1M tokens

  TokenTrackingService._internal() : _hiveService = HiveService.instance;

  TokenTrackingService({HiveService? hiveService})
    : _hiveService = hiveService ?? HiveService.instance;

  Future<Either<Failure, void>> trackTokenUsage({
    required String userId,
    required int promptTokens,
    required int completionTokens,
    required String model,
    String? requestId,
  }) async {
    try {
      final user = _hiveService.usersBox.get(userId);
      if (user == null) {
        return Left(ValidationFailure(message: 'User not found'));
      }

      final cost = _calculateCost(
        promptTokens: promptTokens,
        completionTokens: completionTokens,
        model: model,
      );

      final updatedUser = user.copyWith(
        requestTokensUsed: user.requestTokensUsed + promptTokens,
        responseTokensUsed: user.responseTokensUsed + completionTokens,
        totalCost: user.totalCost + cost,
        updatedAt: DateTime.now(),
      );

      await _hiveService.usersBox.put(userId, updatedUser);

      // Store detailed usage record
      final record = TokenUsageRecord(
        id: requestId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        promptTokens: promptTokens,
        completionTokens: completionTokens,
        cost: cost,
        model: model,
        timestamp: DateTime.now(),
        requestType: 'api_call',
      );

      // Store record and emit to stream
      await _storeUsageRecord(record);
      _controller.add(record);

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, TokenUsageStats>> getUserTokenUsage(
    String userId,
  ) async {
    try {
      final user = _hiveService.usersBox.get(userId);
      if (user == null) {
        return Left(ValidationFailure(message: 'User not found'));
      }

      final stats = TokenUsageStats(
        requestTokensUsed: user.requestTokensUsed,
        responseTokensUsed: user.responseTokensUsed,
        totalTokensUsed: user.requestTokensUsed + user.responseTokensUsed,
        totalCost: user.totalCost,
        requestTokensLimit: 10000, // Default limits
        responseTokensLimit: 10000,
        costLimit: 50.0,
      );

      return Right(stats);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<TokenUsageRecord>>> getUserUsageHistory({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // In a real implementation, you'd query a separate usage records box
      // For now, we'll return mock data based on current usage
      final user = _hiveService.usersBox.get(userId);
      if (user == null) {
        return Left(ValidationFailure(message: 'User not found'));
      }

      // Mock usage history - in production, store actual records
      final records = <TokenUsageRecord>[
        TokenUsageRecord(
          id: '1',
          userId: userId,
          promptTokens: 50,
          completionTokens: 25,
          cost: _calculateCost(
            promptTokens: 50,
            completionTokens: 25,
            model: 'gpt-3.5-turbo',
          ),
          model: 'gpt-3.5-turbo',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          requestType: 'itinerary_generation',
        ),
        TokenUsageRecord(
          id: '2',
          userId: userId,
          promptTokens: 30,
          completionTokens: 45,
          cost: _calculateCost(
            promptTokens: 30,
            completionTokens: 45,
            model: 'gpt-3.5-turbo',
          ),
          model: 'gpt-3.5-turbo',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          requestType: 'itinerary_refinement',
        ),
      ];

      return Right(records);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> resetUserUsage(String userId) async {
    try {
      final user = _hiveService.usersBox.get(userId);
      if (user == null) {
        return Left(ValidationFailure(message: 'User not found'));
      }

      final resetUser = user.copyWith(
        requestTokensUsed: 0,
        responseTokensUsed: 0,
        totalCost: 0.0,
        updatedAt: DateTime.now(),
      );

      await _hiveService.usersBox.put(userId, resetUser);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> checkUsageLimits(String userId) async {
    try {
      final statsResult = await getUserTokenUsage(userId);
      return statsResult.fold((failure) => Left(failure), (stats) {
        final isOverLimit =
            stats.requestTokensUsed >= stats.requestTokensLimit ||
            stats.responseTokensUsed >= stats.responseTokensLimit ||
            stats.totalCost >= stats.costLimit;
        return Right(isOverLimit);
      });
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  double _calculateCost({
    required int promptTokens,
    required int completionTokens,
    required String model,
  }) {
    double inputPrice;
    double outputPrice;

    switch (model.toLowerCase()) {
      case 'gpt-3.5-turbo':
        inputPrice = _gpt4oMiniInputPrice;
        outputPrice = _gpt4oMiniOutputPrice;
        break;
      case 'gpt-4':
      case 'gpt-4-turbo':
        inputPrice = _gpt4InputPrice;
        outputPrice = _gpt4OutputPrice;
        break;
      default:
        // Default to gpt-3.5-turbo pricing
        inputPrice = _gpt4oMiniInputPrice;
        outputPrice = _gpt4oMiniOutputPrice;
    }

    final inputCost = (promptTokens / 1000) * inputPrice;
    final outputCost = (completionTokens / 1000) * outputPrice;

    return inputCost + outputCost;
  }

  Future<void> _storeUsageRecord(TokenUsageRecord record) async {
    // In a production app, you'd store this in a separate Hive box
    // For now, we'll just log it
    print('Usage Record: ${record.toJson()}');
  }

  String formatCost(double cost) {
    if (cost < 0.01) {
      return '\$${(cost * 100).toStringAsFixed(3)}¢';
    }
    return '\$${cost.toStringAsFixed(3)}';
  }

  String getUsagePercentage(int used, int total) {
    if (total == 0) return '0%';
    final percentage = (used / total * 100).clamp(0, 100);
    return '${percentage.toStringAsFixed(1)}%';
  }
}

class TokenUsageStats {
  final int requestTokensUsed;
  final int responseTokensUsed;
  final int totalTokensUsed;
  final double totalCost;
  final int requestTokensLimit;
  final int responseTokensLimit;
  final double costLimit;

  const TokenUsageStats({
    required this.requestTokensUsed,
    required this.responseTokensUsed,
    required this.totalTokensUsed,
    required this.totalCost,
    required this.requestTokensLimit,
    required this.responseTokensLimit,
    required this.costLimit,
  });

  double get requestTokensPercentage =>
      requestTokensLimit > 0 ? (requestTokensUsed / requestTokensLimit) : 0.0;

  double get responseTokensPercentage => responseTokensLimit > 0
      ? (responseTokensUsed / responseTokensLimit)
      : 0.0;

  double get costPercentage => costLimit > 0 ? (totalCost / costLimit) : 0.0;

  bool get isNearLimit =>
      requestTokensPercentage > 0.8 ||
      responseTokensPercentage > 0.8 ||
      costPercentage > 0.8;

  bool get isOverLimit =>
      requestTokensPercentage >= 1.0 ||
      responseTokensPercentage >= 1.0 ||
      costPercentage >= 1.0;
}

class TokenUsageRecord {
  final String id;
  final String userId;
  final int promptTokens;
  final int completionTokens;
  final double cost;
  final String model;
  final DateTime timestamp;
  final String requestType;
  final String? requestId;

  const TokenUsageRecord({
    required this.id,
    required this.userId,
    required this.promptTokens,
    required this.completionTokens,
    required this.cost,
    required this.model,
    required this.timestamp,
    required this.requestType,
    this.requestId,
  });

  int get totalTokens => promptTokens + completionTokens;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'promptTokens': promptTokens,
    'completionTokens': completionTokens,
    'cost': cost,
    'model': model,
    'timestamp': timestamp.toIso8601String(),
    'requestType': requestType,
    'requestId': requestId,
  };

  factory TokenUsageRecord.fromJson(Map<String, dynamic> json) =>
      TokenUsageRecord(
        id: json['id'],
        userId: json['userId'],
        promptTokens: json['promptTokens'],
        completionTokens: json['completionTokens'],
        cost: json['cost'],
        model: json['model'],
        timestamp: DateTime.parse(json['timestamp']),
        requestType: json['requestType'],
        requestId: json['requestId'],
      );
}
