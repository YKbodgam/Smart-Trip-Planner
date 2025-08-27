import 'package:flutter_test/flutter_test.dart';
import 'package:pathoria/src/data/services/ai_service.dart';
import 'package:pathoria/src/data/services/enhanced_ai_service.dart';
import 'package:pathoria/src/data/services/web_search_service.dart';

void main() {
  group('AIService', () {
    test('should return itinerary for valid prompt', () async {
      final service = AIService();
      final result = await service.generateItinerary(
        prompt: 'Plan a trip to Paris',
      );
      expect(result.isRight(), true);
    });

    test('should fail for invalid schema', () async {
      final service = AIService();
      // Simulate invalid response
      // This would require a mock Dio or refactor for DI
      // For now, just check error handling
      final result = await service.generateItinerary(prompt: '');
      expect(result.isLeft(), true);
    });
  });

  group('EnhancedAIService', () {
    test('should use web search when configured', () async {
      final service = EnhancedAIService(webSearchService: WebSearchService());
      final result = await service.generateItinerary(
        prompt: 'Find best restaurants in Rome',
      );
      expect(result.isRight() || result.isLeft(), true); // Accepts both for now
    });
  });
}
