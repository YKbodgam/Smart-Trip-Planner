import '../config/app_environment.dart';

class AppConstants {
  // App Information
  static const String appName = 'Itinerary AI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered travel itinerary planner';

  // API Constants
  static const String groqApiBaseUrl = 'https://api.groq.com/v1';
  static final String groqApiKeyHeader =
      'Authorization: Bearer ${AppEnvironmentConfig.groqApiKey}';

  static const String groqModel = 'gpt-4o';
  static const String groqChatEndpoint = '/chat/completions';
  static const String groqCompletionEndpoint = '/completions';
  static const String groqSearchEndpoint = '/search';
  static const String groqEmbeddingEndpoint = '/embeddings';
  static const String groqModerationEndpoint = '/moderations';
  static const String groqUsageEndpoint = '/usage';
  static const String groqBillingEndpoint = '/billing';
  static const String groqDefaultTemperature = '0.7';
  static const String groqDefaultMaxTokens = '1500';
  static const String groqDefaultTopP = '1.0';
  static const String groqDefaultFrequencyPenalty = '0.0';
  static const String groqDefaultPresencePenalty = '0.0';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Limits
  static const int maxItineraryDays = 30;
  static const int maxChatMessages = 100;
  static const int maxTokensPerRequest = 4000;
  static const int maxTokensPerResponse = 2000;

  // Default Values
  static const String defaultCurrency = 'USD';
  static const String defaultLanguage = 'en';
  static const String defaultCountry = 'US';

  // Error Messages
  static const String networkError =
      'Network connection error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError =
      'An unknown error occurred. Please try again.';
  static const String authError = 'Authentication failed. Please login again.';
  static const String validationError =
      'Please check your input and try again.';
}
