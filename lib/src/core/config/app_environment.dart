import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvironmentConfig {
  static final String groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: false,
  );

  static const bool enablePerformanceMonitoring = bool.fromEnvironment(
    'ENABLE_PERFORMANCE_MONITORING',
    defaultValue: false,
  );

  static const int maxRequestsPerMinute = int.fromEnvironment(
    'MAX_REQUESTS_PER_MINUTE',
    defaultValue: 60,
  );

  static const int maxTokensPerDay = int.fromEnvironment(
    'MAX_TOKENS_PER_DAY',
    defaultValue: 10000,
  );

  static final double maxCostPerDay =
      double.tryParse(
        String.fromEnvironment('MAX_COST_PER_DAY', defaultValue: '50.0'),
      ) ??
      50.0;

  static bool get isGroqConfigured => groqApiKey.isNotEmpty;

  // Validation methods
  static List<String> validateConfiguration() {
    final errors = <String>[];

    if (!isGroqConfigured) {
      errors.add('Groq API key is not configured');
    }

    if (maxRequestsPerMinute <= 0) {
      errors.add('Max requests per minute must be greater than 0');
    }

    if (maxTokensPerDay <= 0) {
      errors.add('Max tokens per day must be greater than 0');
    }

    if (maxCostPerDay <= 0) {
      errors.add('Max cost per day must be greater than 0');
    }

    return errors;
  }

  static Map<String, dynamic> toMap() {
    return {
      'groqConfigured': isGroqConfigured,
      'enableAnalytics': enableAnalytics,
      'enableCrashReporting': enableCrashReporting,
      'enablePerformanceMonitoring': enablePerformanceMonitoring,
      'maxRequestsPerMinute': maxRequestsPerMinute,
      'maxTokensPerDay': maxTokensPerDay,
      'maxCostPerDay': maxCostPerDay,
    };
  }
}
