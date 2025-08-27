import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/itinerary_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/services/ai_service.dart';
import '../../data/services/enhanced_ai_service.dart';
import '../../data/services/web_search_service.dart';
import '../../core/config/environment_config.dart';
import '../../domain/repositories/itinerary_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/ai_service_repository.dart';

final itineraryRepositoryProvider = Provider<ItineraryRepository>((ref) {
  return ItineraryRepositoryImpl();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl();
});

final aiServiceRepositoryProvider = Provider<AIServiceRepository>((ref) {
  if (AppEnvironmentConfig.isGoogleSearchConfigured) {
    return EnhancedAIService(webSearchService: WebSearchService());
  }
  return AIService();
});
