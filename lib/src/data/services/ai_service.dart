import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

import '../../core/config/app_config.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_service_repository.dart';

class AIService implements AIServiceRepository {
  final Dio _dio;

  AIService({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<Either<Failure, Itinerary>> generateItinerary({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.apiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-4',
          'messages': _buildMessages(prompt, chatHistory, existingItinerary),
          'functions': [_getItineraryFunction()],
          'function_call': {'name': 'generate_itinerary'},
          'temperature': 0.7,
          'max_tokens': 2000,
        },
      );

      final functionCall =
          response.data['choices'][0]['message']['function_call'];
      if (functionCall != null &&
          functionCall['name'] == 'generate_itinerary') {
        // TODO: Parse JSON and create Itinerary object
        final mockItinerary = _createMockItinerary();
        return Right(mockItinerary);
      }

      return const Left(
        AIServiceFailure(message: 'Failed to generate itinerary'),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        return const Left(RateLimitFailure(message: 'Rate limit exceeded'));
      } else if (e.response?.statusCode == 401) {
        return const Left(AuthenticationFailure(message: 'Invalid API key'));
      }
      return Left(AIServiceFailure(message: e.message ?? 'AI service error'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> refineItinerary({
    required String prompt,
    required Itinerary currentItinerary,
    required List<ChatMessage> chatHistory,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.apiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-4',
          'messages': _buildRefinementMessages(
            prompt,
            currentItinerary,
            chatHistory,
          ),
          'temperature': 0.7,
          'max_tokens': 1000,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      return Right(content ?? 'I\'ll help you refine your itinerary.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        return const Left(RateLimitFailure(message: 'Rate limit exceeded'));
      } else if (e.response?.statusCode == 401) {
        return const Left(AuthenticationFailure(message: 'Invalid API key'));
      }
      return Left(AIServiceFailure(message: e.message ?? 'AI service error'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, String>> streamResponse({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  }) async* {
    try {
      await _dio.post(
        '${AppConfig.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.apiKey}',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
        data: {
          'model': 'gpt-4',
          'messages': _buildMessages(prompt, chatHistory, existingItinerary),
          'stream': true,
          'temperature': 0.7,
          'max_tokens': 2000,
        },
      );

      // TODO: Implement proper streaming response parsing
      yield const Right('Streaming response...');
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        yield const Left(RateLimitFailure(message: 'Rate limit exceeded'));
      } else if (e.response?.statusCode == 401) {
        yield const Left(AuthenticationFailure(message: 'Invalid API key'));
      } else {
        yield Left(AIServiceFailure(message: e.message ?? 'AI service error'));
      }
    } catch (e) {
      yield Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> searchWebInformation({
    required String query,
    String? location,
    String? dateRange,
  }) async {
    try {
      // TODO: Implement web search functionality
      // This could use Google Search API, Bing API, or other search services
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      return Right({
        'results': [
          {
            'title': 'Best restaurants in $location',
            'url': 'https://example.com/restaurants',
            'snippet': 'Top rated restaurants and dining experiences...',
          },
          {
            'title': 'Things to do in $location',
            'url': 'https://example.com/activities',
            'snippet': 'Popular attractions and activities...',
          },
        ],
      });
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  List<Map<String, dynamic>> _buildMessages(
    String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  ) {
    final messages = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content':
            '''You are a professional travel planner AI. Generate detailed, personalized travel itineraries based on user preferences. 
        Always include specific times, activities, locations with coordinates when possible, and practical travel advice.
        Format your response as a structured JSON itinerary.''',
      },
    ];

    // Add chat history
    if (chatHistory != null) {
      for (final message in chatHistory) {
        messages.add({
          'role': message.isUser ? 'user' : 'assistant',
          'content': message.content,
        });
      }
    }

    // Add current prompt
    messages.add({'role': 'user', 'content': prompt});

    return messages;
  }

  List<Map<String, dynamic>> _buildRefinementMessages(
    String prompt,
    Itinerary currentItinerary,
    List<ChatMessage> chatHistory,
  ) {
    final messages = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content':
            '''You are a professional travel planner AI. Help users refine and modify their existing travel itineraries.
        Be helpful and provide specific suggestions based on their requests.''',
      },
    ];

    // Add chat history
    for (final message in chatHistory) {
      messages.add({
        'role': message.isUser ? 'user' : 'assistant',
        'content': message.content,
      });
    }

    // Add current refinement request
    messages.add({'role': 'user', 'content': prompt});

    return messages;
  }

  Map<String, dynamic> _getItineraryFunction() {
    return {
      'name': 'generate_itinerary',
      'description': 'Generate a structured travel itinerary',
      'parameters': {
        'type': 'object',
        'properties': {
          'title': {'type': 'string'},
          'startDate': {'type': 'string'},
          'endDate': {'type': 'string'},
          'days': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'date': {'type': 'string'},
                'summary': {'type': 'string'},
                'items': {
                  'type': 'array',
                  'items': {
                    'type': 'object',
                    'properties': {
                      'time': {'type': 'string'},
                      'activity': {'type': 'string'},
                      'location': {'type': 'string'},
                      'description': {'type': 'string'},
                      'estimatedCost': {'type': 'number'},
                      'category': {'type': 'string'},
                    },
                    'required': ['time', 'activity'],
                  },
                },
              },
              'required': ['date', 'summary', 'items'],
            },
          },
        },
        'required': ['title', 'startDate', 'endDate', 'days'],
      },
    };
  }

  Itinerary _createMockItinerary() {
    return Itinerary(
      title: "Bali 7-Day Peaceful Retreat",
      startDate: "2025-04-10",
      endDate: "2025-04-17",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      days: [
        ItineraryDay(
          date: "2025-04-10",
          summary: "Arrival in Bali & Settle in Ubud",
          items: [
            ItineraryItem(
              time: "Morning",
              activity: "Arrive in Bali, Denpasar Airport.",
            ),
            ItineraryItem(
              time: "Transfer",
              activity: "Private driver to Ubud (around 1.5 hours).",
            ),
            ItineraryItem(
              time: "Accommodation",
              activity:
                  "Check-in at a peaceful boutique hotel or villa in Ubud (e.g., Ubud Aura Retreat or Komaneka at Bisma).",
            ),
            ItineraryItem(
              time: "Afternoon",
              activity:
                  "Explore Ubud's local area, walk around the tranquil rice terraces at Tegallalang.",
            ),
            ItineraryItem(
              time: "Evening",
              activity:
                  "Dinner at Locavore (known for farm-to-table dishes in a peaceful setting)",
            ),
          ],
        ),
      ],
    );
  }
}
