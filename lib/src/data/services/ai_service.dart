import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/entities/chat_message.dart';
import '../../core/config/environment_config.dart';
import '../../domain/repositories/ai_service_repository.dart';

import 'token_tracking_service.dart'; // Added token tracking service import

class AIService implements AIServiceRepository {
  final Dio _dio;
  final TokenTrackingService
  _tokenTrackingService; // Added token tracking service
  static const String _model = 'gpt-4o-mini'; // Low-cost, current model

  AIService({
    Dio? dio,
    TokenTrackingService?
    tokenTrackingService, // Added token tracking service parameter
  }) : _dio = dio ?? _createDioInstance(),
       _tokenTrackingService = tokenTrackingService ?? TokenTrackingService();

  static Dio _createDioInstance() {
    final dio = Dio();
    dio.options.baseUrl = EnvironmentConfig.openaiBaseUrl;
    dio.options.headers = {
      'Authorization': 'Bearer ${EnvironmentConfig.openaiApiKey}',
      'OpenAI-Organization': EnvironmentConfig.openaiOrganizationId,
      'Content-Type': 'application/json',
    };
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 60);
    return dio;
  }

  @override
  Future<Either<Failure, Itinerary>> generateItinerary({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
    String? userId, // Added userId parameter for token tracking
  }) async {
    try {
      if (!EnvironmentConfig.isOpenAIConfigured) {
        return Left(
          ConfigurationFailure(message: 'OpenAI API key not configured'),
        );
      }

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': _buildMessages(prompt, chatHistory, existingItinerary),
          'tools': [
            _getItineraryTool(),
          ], // Updated to use tools instead of functions
          'tool_choice': {
            'type': 'function',
            'function': {'name': 'generate_itinerary'},
          },
          'temperature': 0.7,
          'max_tokens': 1200,
        },
      );

      final usage = response.data['usage'];
      if (usage != null && userId != null) {
        await _tokenTrackingService.trackTokenUsage(
          userId: userId,
          promptTokens: usage['prompt_tokens'] ?? 0,
          completionTokens: usage['completion_tokens'] ?? 0,
          model: _model,
          requestId: response.data['id'],
        );
      }

      final choice = response.data['choices'][0];
      final toolCalls = choice['message']['tool_calls'];

      if (toolCalls != null && toolCalls.isNotEmpty) {
        final toolCall = toolCalls[0];
        if (toolCall['function']['name'] == 'generate_itinerary') {
          final argumentsJson = toolCall['function']['arguments'];
          final itineraryData = json.decode(argumentsJson);
          try {
            final itinerary = _parseItineraryFromJson(itineraryData);
            return Right(itinerary);
          } on FormatException catch (e) {
            return Left(
              AIServiceFailure(
                message: 'Itinerary schema validation failed: \\${e.message}',
              ),
            );
          }
        }
      }

      return Left(AIServiceFailure(message: 'Failed to generate itinerary'));
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> refineItinerary({
    required String prompt,
    required Itinerary currentItinerary,
    required List<ChatMessage> chatHistory,
    String? userId, // Added userId parameter for token tracking
  }) async {
    try {
      if (!EnvironmentConfig.isOpenAIConfigured) {
        return Left(
          ConfigurationFailure(message: 'OpenAI API key not configured'),
        );
      }

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': _buildRefinementMessages(
            prompt,
            currentItinerary,
            chatHistory,
          ),
          'temperature': 0.7,
          'max_tokens': 800,
        },
      );

      final usage = response.data['usage'];
      if (usage != null && userId != null) {
        await _tokenTrackingService.trackTokenUsage(
          userId: userId,
          promptTokens: usage['prompt_tokens'] ?? 0,
          completionTokens: usage['completion_tokens'] ?? 0,
          model: _model,
          requestId: response.data['id'],
        );
      }

      final content = response.data['choices'][0]['message']['content'];
      return Right(content ?? 'I\'ll help you refine your itinerary.');
    } on DioException catch (e) {
      return _handleDioException(e);
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
      if (!EnvironmentConfig.isOpenAIConfigured) {
        yield Left(
          ConfigurationFailure(message: 'OpenAI API key not configured'),
        );
        return;
      }

      final response = await _dio.post(
        '/chat/completions',
        options: Options(responseType: ResponseType.stream),
        data: {
          'model': _model,
          'messages': _buildMessages(prompt, chatHistory, existingItinerary),
          'stream': true,
          'temperature': 0.7,
          'max_tokens': 1200,
        },
      );

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.removeLast(); // Keep incomplete line in buffer

        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data == '[DONE]') return;

            try {
              final jsonData = json.decode(data);
              final delta = jsonData['choices']?[0]?['delta'];
              if (delta != null && delta['content'] != null) {
                yield Right(delta['content'] as String);
              }
            } catch (e) {
              // Skip malformed JSON chunks
              continue;
            }
          }
        }
      }
    } on DioException catch (e) {
      yield _handleDioException(
        e,
      ).fold((failure) => Left(failure), (success) => const Right(''));
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
      if (!EnvironmentConfig.isGoogleSearchConfigured) {
        return Left(
          ConfigurationFailure(message: 'Google Search API not configured'),
        );
      }

      String searchQuery = query;
      if (location != null) {
        searchQuery += ' in $location';
      }
      if (dateRange != null) {
        searchQuery += ' $dateRange';
      }

      final searchDio = Dio();
      final response = await searchDio.get(
        'https://www.googleapis.com/customsearch/v1',
        queryParameters: {
          'key': EnvironmentConfig.googleSearchApiKey,
          'cx': EnvironmentConfig.googleSearchEngineId,
          'q': searchQuery,
          'num': 5,
        },
      );

      final results = response.data['items'] as List<dynamic>? ?? [];
      return Right({
        'results': results
            .map(
              (item) => {
                'title': item['title'] ?? '',
                'url': item['link'] ?? '',
                'snippet': item['snippet'] ?? '',
              },
            )
            .toList(),
        'query': searchQuery,
      });
    } on DioException catch (e) {
      return Left(NetworkFailure(message: e.message ?? 'Search API error'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, int>>> getTokenUsage({
    required String prompt,
    List<ChatMessage>? chatHistory,
  }) async {
    try {
      // Estimate tokens (rough calculation: ~4 characters per token)
      final messages = _buildMessages(prompt, chatHistory, null);
      final totalText = messages.map((m) => m['content']).join(' ');
      final estimatedTokens = (totalText.length / 4).ceil();

      return Right({
        'prompt_tokens': estimatedTokens,
        'completion_tokens': 0, // Will be updated after response
        'total_tokens': estimatedTokens,
      });
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
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

    // Add chat history (limit to last 6 to control tokens)
    if (chatHistory != null && chatHistory.isNotEmpty) {
      final limited = chatHistory.length > 6
          ? chatHistory.sublist(chatHistory.length - 6)
          : chatHistory;
      for (final message in limited) {
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

  Map<String, dynamic> _getItineraryTool() {
    return {
      'type': 'function',
      'function': {
        'name': 'generate_itinerary',
        'description':
            'Generate a structured travel itinerary with detailed daily activities',
        'parameters': {
          'type': 'object',
          'properties': {
            'title': {
              'type': 'string',
              'description': 'A descriptive title for the itinerary',
            },
            'startDate': {
              'type': 'string',
              'description': 'Start date in YYYY-MM-DD format',
            },
            'endDate': {
              'type': 'string',
              'description': 'End date in YYYY-MM-DD format',
            },
            'totalCost': {
              'type': 'number',
              'description': 'Estimated total cost in USD',
            },
            'currency': {
              'type': 'string',
              'description': 'Currency code (e.g., USD, EUR)',
            },
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
      },
    };
  }

  Itinerary _parseItineraryFromJson(Map<String, dynamic> json) {
    // Schema validation
    if (json['title'] == null ||
        json['startDate'] == null ||
        json['endDate'] == null ||
        json['days'] == null) {
      throw FormatException(
        'Itinerary JSON schema invalid: missing required fields',
      );
    }
    if (json['days'] is! List || (json['days'] as List).isEmpty) {
      throw FormatException(
        'Itinerary JSON schema invalid: days must be a non-empty list',
      );
    }
    final days = (json['days'] as List<dynamic>).map((dayJson) {
      final items = (dayJson['items'] as List<dynamic>).map((itemJson) {
        return ItineraryItem(
          time: itemJson['time'] ?? '',
          activity: itemJson['activity'] ?? '',
          location: itemJson['location'],
          description: itemJson['description'],
          estimatedCost: itemJson['estimatedCost']?.toDouble(),
          category: itemJson['category'],
        );
      }).toList();

      return ItineraryDay(
        date: dayJson['date'] ?? '',
        summary: dayJson['summary'] ?? '',
        items: items,
      );
    }).toList();

    return Itinerary(
      title: json['title'] ?? 'Untitled Itinerary',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      totalCost: json['totalCost']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      days: days,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Either<Failure, T> _handleDioException<T>(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (status == 429) {
      final errMsg = data is Map && data['error'] is Map
          ? (data['error']['message'] as String? ??
                'Rate limit or quota exceeded')
          : 'Rate limit or quota exceeded';
      final errCode = data is Map && data['error'] is Map
          ? data['error']['code'] as String?
          : null;
      if (errCode == 'insufficient_quota') {
        return Left(
          RateLimitFailure(
            message:
                'You have exceeded your current quota. Please check plan and billing.',
            code: status,
            details: errMsg,
          ),
        );
      }
      return Left(
        RateLimitFailure(
          message: 'Too many requests. Please try again later.',
          code: status,
          details: errMsg,
        ),
      );
    } else if (status == 401) {
      return Left(
        AuthenticationFailure(
          message: 'Invalid API key',
          code: status,
          details: data?.toString(),
        ),
      );
    } else if (status == 400) {
      return Left(
        ValidationFailure(
          message: 'Invalid request parameters',
          code: status,
          details: data?.toString(),
        ),
      );
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return Left(NetworkFailure(message: 'Connection timeout'));
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return Left(NetworkFailure(message: 'Response timeout'));
    }
    return Left(
      AIServiceFailure(
        message: e.message ?? 'AI service error',
        code: status,
        details: data?.toString(),
      ),
    );
  }
}
