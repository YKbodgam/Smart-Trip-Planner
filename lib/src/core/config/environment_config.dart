import 'app_environment.dart';

export 'app_environment.dart';

// Backward compatibility - deprecated, use AppEnvironmentConfig instead
@Deprecated('Use AppEnvironmentConfig instead')
class EnvironmentConfig {
  static String get openaiApiKey => AppEnvironmentConfig.openaiApiKey;
  static String get openaiBaseUrl => AppEnvironmentConfig.openaiBaseUrl;
  static String get googleSearchApiKey =>
      AppEnvironmentConfig.googleSearchApiKey;
  static String get googleSearchEngineId =>
      AppEnvironmentConfig.googleSearchEngineId;
  static bool get isOpenAIConfigured => AppEnvironmentConfig.isOpenAIConfigured;
  static bool get isGoogleSearchConfigured =>
      AppEnvironmentConfig.isGoogleSearchConfigured;
}
