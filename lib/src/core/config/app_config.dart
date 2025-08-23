import 'package:flutter/foundation.dart';

import '../../core/database/hive_service.dart';
import 'environment_config.dart';

class AppConfig {
  static late HiveService _hiveService; // Changed from Isar to Hive

  // Environment-based configuration
  static String get appName => AppEnvironmentConfig.appName;
  static String get appVersion => AppEnvironmentConfig.appVersion;
  static AppEnvironment get environment => AppEnvironmentConfig.environment;
  static bool get isDebug => AppEnvironmentConfig.debugMode;

  // API Configuration
  static String get openaiBaseUrl => AppEnvironmentConfig.openaiBaseUrl;
  static String get openaiApiKey => AppEnvironmentConfig.openaiApiKey;
  static String get googleSearchApiKey =>
      AppEnvironmentConfig.googleSearchApiKey;
  static String get googleSearchEngineId =>
      AppEnvironmentConfig.googleSearchEngineId;

  // Feature flags
  static bool get enableAnalytics => AppEnvironmentConfig.enableAnalytics;
  static bool get enableCrashReporting =>
      AppEnvironmentConfig.enableCrashReporting;
  static bool get enablePerformanceMonitoring =>
      AppEnvironmentConfig.enablePerformanceMonitoring;

  // Rate limiting
  static int get maxRequestsPerMinute =>
      AppEnvironmentConfig.maxRequestsPerMinute;
  static int get maxTokensPerDay => AppEnvironmentConfig.maxTokensPerDay;
  static double get maxCostPerDay => AppEnvironmentConfig.maxCostPerDay;

  // Database service getter
  static HiveService get hiveService => _hiveService;

  static Future<void> initialize() async {
    try {
      // Print configuration in debug mode
      if (kDebugMode) {
        AppEnvironmentConfig.printConfiguration();
      }

      // Validate configuration
      final validationErrors = AppEnvironmentConfig.validateConfiguration();
      if (validationErrors.isNotEmpty && environment.isProduction) {
        throw ConfigurationException(
          'Configuration validation failed: ${validationErrors.join(', ')}',
        );
      } else if (validationErrors.isNotEmpty && kDebugMode) {
        print('Configuration warnings: ${validationErrors.join(', ')}');
      }

      // Initialize Hive database service
      _hiveService = HiveService.instance;
      await _hiveService.init();

      if (kDebugMode) {
        print('App configuration initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize app configuration: $e');
      }
      rethrow;
    }
  }

  static Future<void> dispose() async {
    try {
      await _hiveService.close();
      if (kDebugMode) {
        print('App configuration disposed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing app configuration: $e');
      }
    }
  }

  // Configuration status methods
  static bool get isOpenAIConfigured => AppEnvironmentConfig.isOpenAIConfigured;
  static bool get isGoogleSearchConfigured =>
      AppEnvironmentConfig.isGoogleSearchConfigured;
  static bool get isFirebaseConfigured =>
      AppEnvironmentConfig.isFirebaseConfigured;

  // Get configuration summary
  static Map<String, dynamic> getConfigurationSummary() {
    return AppEnvironmentConfig.toMap();
  }

  // Environment-specific settings
  static Duration get httpTimeout {
    switch (environment) {
      case AppEnvironment.development:
        return const Duration(seconds: 30);
      case AppEnvironment.staging:
        return const Duration(seconds: 45);
      case AppEnvironment.production:
        return const Duration(seconds: 60);
    }
  }

  static int get maxRetryAttempts {
    switch (environment) {
      case AppEnvironment.development:
        return 2;
      case AppEnvironment.staging:
        return 3;
      case AppEnvironment.production:
        return 3;
    }
  }

  static Duration get cacheExpiration {
    switch (environment) {
      case AppEnvironment.development:
        return const Duration(minutes: 5);
      case AppEnvironment.staging:
        return const Duration(minutes: 15);
      case AppEnvironment.production:
        return const Duration(hours: 1);
    }
  }
}

class ConfigurationException implements Exception {
  final String message;

  const ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}
