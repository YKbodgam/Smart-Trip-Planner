import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/itinerary_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/ai_service_repository.dart';
import '../../data/services/groq_service.dart';
import '../../data/services/web_search_service.dart';
import '../../data/services/token_usage_service.dart';
import '../../domain/repositories/itinerary_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/ai_service_repository.dart';

// Service providers
final groqServiceProvider = Provider<GroqService>((ref) {
  return GroqService();
});

final webSearchServiceProvider = Provider<WebSearchService>((ref) {
  return WebSearchService();
});

final tokenUsageServiceProvider = Provider<TokenUsageService>((ref) {
  return TokenUsageService();
});

// Repository providers
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
  final groqService = ref.watch(groqServiceProvider);
  final webSearchService = ref.watch(webSearchServiceProvider);
  final tokenUsageService = ref.watch(tokenUsageServiceProvider);

  return AIServiceRepositoryImpl(
    groqService: groqService,
    webSearchService: webSearchService,
    tokenUsageService: tokenUsageService,
  );
});
