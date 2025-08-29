import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

import '../../core/config/environment_config.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/entities/chat_message.dart';

import 'ai_service.dart';
import 'web_search_service.dart';

class EnhancedAIService extends AIService {
  final Dio _dio;
  final WebSearchService _webSearchService;

  EnhancedAIService({Dio? dio, WebSearchService? webSearchService})
    : _dio = dio ?? _createConfiguredDio(),
      _webSearchService = webSearchService ?? WebSearchService(),
      super(dio: dio ?? _createConfiguredDio());

  static Dio _createConfiguredDio() {
    final dio = Dio();
    dio.options.baseUrl = EnvironmentConfig.openaiBaseUrl;
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${EnvironmentConfig.openaiApiKey}',
      'OpenAI-Organization': EnvironmentConfig.openaiOrganizationId,
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
    String? userId,
  }) async {
    try {
      // Extract location and dates from prompt for web search
      final searchContext = _extractSearchContext(prompt);

      // Perform web search for real-time information
      Map<String, List<SearchResult>>? searchResults;
      if (searchContext['location'] != null) {
        final searchResult = await _webSearchService.searchComprehensiveInfo(
          location: searchContext['location']!,
          dateRange: searchContext['dateRange'],
          interests: searchContext['interests'] != null
              ? [searchContext['interests']!]
              : [],
        );

        searchResult.fold(
          (failure) => searchResults = null,
          (results) => searchResults = results,
        );
      }

      // Generate itinerary with enhanced context
      return await _generateItineraryWithContext(
        prompt: prompt,
        chatHistory: chatHistory,
        existingItinerary: existingItinerary,
        searchResults: searchResults,
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Itinerary _parseItineraryFromJson(Map<String, dynamic> json) {
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

  Future<Either<Failure, Itinerary>> _generateItineraryWithContext({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
    Map<String, List<SearchResult>>? searchResults,
  }) async {
    try {
      if (!EnvironmentConfig.isOpenAIConfigured) {
        print('Debug: OpenAI API key not configured');
        return Left(
          ConfigurationFailure(message: 'OpenAI API key not configured'),
        );
      }

      print('Debug: Building enhanced messages');
      final messages = _buildEnhancedMessages(
        prompt,
        chatHistory,
        existingItinerary,
        searchResults,
      );

      print(
        'Debug: Sending POST request to /chat/completions with messages: $messages',
      );
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-4o-mini',
          'messages': messages,
          'tools': [_getEnhancedItineraryTool()],
          'tool_choice': {
            'type': 'function',
            'function': {'name': 'generate_itinerary'},
          },
          'temperature': 0.7,
          'max_tokens': 1200,
        },
      );
      print('Debug: Received response: ${response.data}');

      final choice = response.data['choices'][0];
      final message = choice['message'] ?? {};

      // Prefer modern tool_calls format
      final toolCalls = message['tool_calls'];
      if (toolCalls != null && toolCalls is List && toolCalls.isNotEmpty) {
        final firstCall = toolCalls[0];
        final function = firstCall['function'];
        if (function != null && function['name'] == 'generate_itinerary') {
          final argumentsJson = function['arguments'];
          print('Debug: Tool call arguments: $argumentsJson');
          try {
            final itineraryData = json.decode(argumentsJson);
            final itinerary = _parseItineraryFromJson(itineraryData);
            print('Debug: Successfully parsed itinerary');
            return Right(itinerary);
          } catch (e) {
            print('Debug: Error parsing itinerary data - ${e.toString()}');
            return Left(
              AIServiceFailure(
                message: 'Failed to parse itinerary data: ${e.toString()}',
              ),
            );
          }
        }
      }

      // Legacy function_call fallback
      final functionCall = message['function_call'];
      if (functionCall != null &&
          functionCall['name'] == 'generate_itinerary') {
        final argumentsJson = functionCall['arguments'];
        print('Debug: Legacy function call arguments: $argumentsJson');
        try {
          final itineraryData = json.decode(argumentsJson);
          final itinerary = _parseItineraryFromJson(itineraryData);
          print('Debug: Successfully parsed itinerary');
          return Right(itinerary);
        } catch (e) {
          print('Debug: Error parsing itinerary data - ${e.toString()}');
          return Left(
            AIServiceFailure(
              message: 'Failed to parse itinerary data: ${e.toString()}',
            ),
          );
        }
      }

      print('Debug: No matching tool/function call for generate_itinerary');
      return Left(AIServiceFailure(message: 'Failed to generate itinerary'));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      print(
        'Debug: DioException encountered - status: $status, message: ${e.message}, data: $data',
      );

      // Map common API errors to domain failures
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
    } catch (e) {
      print('Debug: Exception encountered - ${e.toString()}');
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  List<Map<String, dynamic>> _buildEnhancedMessages(
    String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
    Map<String, List<SearchResult>>? searchResults,
  ) {
    final messages = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content':
            '''You are a professional travel planner AI with access to real-time information. 
        Generate detailed, personalized travel itineraries based on user preferences and current information.
        Always include specific times, activities, locations with coordinates when possible, and practical travel advice.
        Use the provided search results to include current, accurate information about restaurants, attractions, hotels, and local events.
        Format your response as a structured JSON itinerary.''',
      },
    ];

    // Add search context if available (trim to avoid token blowup)
    if (searchResults != null && searchResults.isNotEmpty) {
      final searchContext = _formatSearchResultsForAI(searchResults);
      messages.add({
        'role': 'system',
        'content':
            'Current real-time information for your itinerary planning:\n$searchContext',
      });
    }

    // Add chat history (limit to last 6)
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

  Map<String, String?> _extractSearchContext(String prompt) {
    // Simple extraction logic - in production, you might use NLP libraries
    final context = <String, String?>{
      'location': null,
      'dateRange': null,
      'interests': null,
    };

    // Extract location (look for common patterns)
    final locationPatterns = [
      RegExp(r'in ([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)', caseSensitive: false),
      RegExp(r'to ([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)', caseSensitive: false),
      RegExp(r'visit ([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)', caseSensitive: false),
    ];

    for (final pattern in locationPatterns) {
      final match = pattern.firstMatch(prompt);
      if (match != null) {
        context['location'] = match.group(1);
        break;
      }
    }

    // Extract date range (look for month/date patterns)
    final datePattern = RegExp(
      r'(January|February|March|April|May|June|July|August|September|October|November|December|next \w+|\d+ days)',
      caseSensitive: false,
    );
    final dateMatch = datePattern.firstMatch(prompt);
    if (dateMatch != null) {
      context['dateRange'] = dateMatch.group(0);
    }

    return context;
  }

  String _formatSearchResultsForAI(
    Map<String, List<SearchResult>> searchResults,
  ) {
    final buffer = StringBuffer();

    int totalItems = 0;
    searchResults.forEach((category, results) {
      if (results.isNotEmpty && totalItems < 9) {
        buffer.writeln('\n$category:');
        for (final result in results.take(3)) {
          if (totalItems >= 9) break;
          final title = (result.title ?? '').toString();
          final snippet = (result.snippet ?? '').toString();
          final url = (result.url ?? '').toString();
          buffer.writeln(
            '- ${title.length > 120 ? title.substring(0, 117) + '...' : title}',
          );
          final trimmedSnippet = snippet.length > 160
              ? snippet.substring(0, 157) + '...'
              : snippet;
          buffer.writeln('  $trimmedSnippet');
          buffer.writeln('  URL: $url');
          totalItems++;
        }
      }
    });

    return buffer.toString();
  }

  Map<String, dynamic> _getEnhancedItineraryTool() {
    return {
      'type': 'function',
      'function': {
        'name': 'generate_itinerary',
        'description':
            'Generate a structured travel itinerary with real-time information and detailed daily activities',
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
              'description':
                  'Estimated total cost in USD based on current prices',
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
                        'location': {
                          'type': 'string',
                          'description':
                              'Location with coordinates if available (lat,lng format)',
                        },
                        'description': {'type': 'string'},
                        'estimatedCost': {'type': 'number'},
                        'category': {
                          'type': 'string',
                          'enum': [
                            'dining',
                            'attraction',
                            'accommodation',
                            'transportation',
                            'activity',
                            'shopping',
                            'entertainment',
                          ],
                        },
                        'websiteUrl': {'type': 'string'},
                        'rating': {'type': 'number'},
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
}
