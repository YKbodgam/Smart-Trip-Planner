class TokenUsageStats {
  final String model;
  final int sessionTokens;
  final int totalTokens;
  final double totalCost;
  final DateTime? lastRequestTime;

  const TokenUsageStats({
    required this.model,
    required this.sessionTokens,
    required this.totalTokens,
    required this.totalCost,
    this.lastRequestTime,
  });
}

class TokenUsageRecord {
  final String model;
  final int tokens;
  final double cost;
  final DateTime timestamp;

  const TokenUsageRecord({
    required this.model,
    required this.tokens,
    required this.cost,
    required this.timestamp,
  });
}
