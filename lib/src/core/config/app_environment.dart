enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment get current {
    const environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );
    switch (environment.toLowerCase()) {
      case 'staging':
        return AppEnvironment.staging;
      case 'production':
        return AppEnvironment.production;
      default:
        return AppEnvironment.development;
    }
  }

  bool get isDevelopment => this == AppEnvironment.development;
  bool get isStaging => this == AppEnvironment.staging;
  bool get isProduction => this == AppEnvironment.production;
  bool get isDebug => isDevelopment || isStaging;
}

class AppEnvironmentConfig {
  static const String openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static const String openaiBaseUrl = String.fromEnvironment(
    'OPENAI_BASE_URL',
    defaultValue: 'https://api.openai.com/v1',
  );

  static const String googleSearchApiKey = String.fromEnvironment(
    'GOOGLE_SEARCH_API_KEY',
    defaultValue: '',
  );

  static const String googleSearchEngineId = String.fromEnvironment(
    'GOOGLE_SEARCH_ENGINE_ID',
    defaultValue: '',
  );

  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Smart Trip Planner',
  );

  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  static const bool debugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: true,
  );

  static const String databaseEncryptionKey = String.fromEnvironment(
    'DATABASE_ENCRYPTION_KEY',
    defaultValue: '',
  );

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

  // Computed properties
  static AppEnvironment get environment => AppEnvironment.current;

  static bool get isOpenAIConfigured => openaiApiKey.isNotEmpty;

  static bool get isGoogleSearchConfigured =>
      googleSearchApiKey.isNotEmpty && googleSearchEngineId.isNotEmpty;

  static bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty && firebaseProjectId.isNotEmpty;

  static bool get isDatabaseEncrypted => databaseEncryptionKey.isNotEmpty;

  // Validation methods
  static List<String> validateConfiguration() {
    final errors = <String>[];

    if (!isOpenAIConfigured) {
      errors.add('OpenAI API key is not configured');
    }

    if (!isGoogleSearchConfigured) {
      errors.add('Google Search API is not configured');
    }

    if (environment.isProduction && !isDatabaseEncrypted) {
      errors.add('Database encryption key is required in production');
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
      'environment': environment.name,
      'appName': appName,
      'appVersion': appVersion,
      'debugMode': debugMode,
      'openaiConfigured': isOpenAIConfigured,
      'googleSearchConfigured': isGoogleSearchConfigured,
      'firebaseConfigured': isFirebaseConfigured,
      'databaseEncrypted': isDatabaseEncrypted,
      'enableAnalytics': enableAnalytics,
      'enableCrashReporting': enableCrashReporting,
      'enablePerformanceMonitoring': enablePerformanceMonitoring,
      'maxRequestsPerMinute': maxRequestsPerMinute,
      'maxTokensPerDay': maxTokensPerDay,
      'maxCostPerDay': maxCostPerDay,
    };
  }

  static void printConfiguration() {
    if (debugMode) {
      print('=== App Environment Configuration ===');
      print('Environment: ${environment.name}');
      print('App Name: $appName');
      print('App Version: $appVersion');
      print('Debug Mode: $debugMode');
      print('OpenAI Configured: $isOpenAIConfigured');
      print('Google Search Configured: $isGoogleSearchConfigured');
      print('Firebase Configured: $isFirebaseConfigured');
      print('Database Encrypted: $isDatabaseEncrypted');
      print('Analytics Enabled: $enableAnalytics');
      print('Crash Reporting Enabled: $enableCrashReporting');
      print('Performance Monitoring Enabled: $enablePerformanceMonitoring');
      print('Max Requests/Min: $maxRequestsPerMinute');
      print('Max Tokens/Day: $maxTokensPerDay');
      print('Max Cost/Day: \$${maxCostPerDay.toStringAsFixed(2)}');
      print('=====================================');
    }
  }
}
