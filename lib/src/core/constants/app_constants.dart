class AppConstants {
  // App Information
  static const String appName = 'Smart Trip Planner';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered travel itinerary planner';

  // API Constants
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  // Database Constants
  static const String databaseName = 'smart_trip_planner.db';
  static const int databaseVersion = 1;

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
