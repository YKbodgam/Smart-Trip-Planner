import 'package:flutter/foundation.dart';

import '../../core/database/hive_service.dart';
import 'app_environment.dart';

class AppConfig {
  static late HiveService _hiveService; // Changed from Isar to Hive

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
      // Validate configuration
      final validationErrors = AppEnvironmentConfig.validateConfiguration();

      if (validationErrors.isNotEmpty) {
        throw ConfigurationException(
          'Configuration validation failed: ${validationErrors.join(', ')}',
        );
      }
      //
      else if (validationErrors.isNotEmpty && kDebugMode) {
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

  // Get configuration summary
  static Map<String, dynamic> getConfigurationSummary() {
    return AppEnvironmentConfig.toMap();
  }
}

class ConfigurationException implements Exception {
  final String message;

  const ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}
