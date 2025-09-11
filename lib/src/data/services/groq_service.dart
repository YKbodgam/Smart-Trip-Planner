import 'dart:async';
import 'dart:convert';
import 'dart:math' show min;
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/config/app_environment.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/entities/chat_message.dart';

// Helper class for caching responses
class _CachedResponse {
  final dynamic data;
  final DateTime timestamp;

  _CachedResponse(this.data, this.timestamp);
}

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _model =
      'gemma2-9b-it'; // Using Llama 3.1 for better structured output

  // Timeout constants for better performance
  static const Duration defaultTimeout = Duration(seconds: 60);
  static const Duration streamTimeout = Duration(seconds: 120);

  // Simple in-memory cache to avoid repeated identical requests
  static final Map<String, _CachedResponse> _responseCache = {};
  static const int _maxCacheItems = 50;
  static const Duration _cacheTtl = Duration(hours: 1);

  final http.Client _client;

  GroqService({http.Client? client}) : _client = client ?? http.Client();

  Future<Either<Failure, Map<String, dynamic>>> generateStructuredItinerary({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
    bool useCache = true,
  }) async {
    try {
      if (!AppEnvironmentConfig.isGroqConfigured) {
        return Left(
          ConfigurationFailure(message: 'Groq API key is not configured'),
        );
      }

      // Generate cache key from prompt and itinerary details
      final cacheKey = _generateCacheKey(
        prompt,
        chatHistory,
        existingItinerary,
      );

      // Check cache for identical request if caching is enabled
      if (useCache && _responseCache.containsKey(cacheKey)) {
        final cachedResponse = _responseCache[cacheKey]!;
        // Check if cache is still valid
        if (DateTime.now().difference(cachedResponse.timestamp) < _cacheTtl) {
          return Right(cachedResponse.data as Map<String, dynamic>);
        } else {
          // Remove expired cache entry
          _responseCache.remove(cacheKey);
        }
      }

      final messages = _buildSystemPromptForStructuredItinerary(
        prompt,
        chatHistory,
        existingItinerary,
      );

      try {
        final response = await _client
            .post(
              Uri.parse('$_baseUrl/chat/completions'),
              headers: {
                'Authorization': 'Bearer ${AppEnvironmentConfig.groqApiKey}',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': _model,
                'messages': messages,
                'temperature':
                    0.2, // Lower temperature for more structured output
                'max_tokens': 4000,
                'stream': false,
              }),
            )
            .timeout(
              defaultTimeout,
              onTimeout: () {
                throw TimeoutException(
                  'Request timed out after ${defaultTimeout.inSeconds} seconds',
                );
              },
            );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices'][0]['message']['content'] as String;

          // Token usage tracking
          final usage = data['usage'];
          final promptTokens = usage['prompt_tokens'];
          final completionTokens = usage['completion_tokens'];
          final totalTokens = usage['total_tokens'];

          // Extract JSON from the response
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
          if (jsonMatch != null) {
            try {
              final jsonContent = jsonMatch.group(0)!;
              final itineraryData = jsonDecode(jsonContent);

              final result = {
                'itinerary': itineraryData,
                'usage': {
                  'prompt_tokens': promptTokens,
                  'completion_tokens': completionTokens,
                  'total_tokens': totalTokens,
                },
                'raw_response': content,
              };

              // Save to cache if caching is enabled
              if (useCache) {
                _responseCache[cacheKey] = _CachedResponse(
                  result,
                  DateTime.now(),
                );

                // Clean cache if too many items
                if (_responseCache.length > _maxCacheItems) {
                  _cleanCache();
                }
              }

              return Right(result);
            } catch (e) {
              return Left(
                ParsingFailure(
                  message: 'Failed to parse JSON response: ${e.toString()}',
                ),
              );
            }
          } else {
            return Left(
              ParsingFailure(message: 'No JSON found in the response'),
            );
          }
        } else if (response.statusCode == 401) {
          return Left(AuthenticationFailure(message: 'Invalid Groq API key'));
        } else if (response.statusCode == 429) {
          return Left(
            RateLimitFailure(message: 'Groq API rate limit exceeded'),
          );
        } else {
          return Left(
            NetworkFailure(message: 'Groq API error: ${response.statusCode}'),
          );
        }
      } on TimeoutException {
        return Left(
          NetworkFailure(message: 'Request timed out. Please try again.'),
        );
      }
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Generate a unique cache key based on request parameters
  String _generateCacheKey(
    String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  ) {
    final buffer = StringBuffer(prompt);

    if (chatHistory != null && chatHistory.isNotEmpty) {
      buffer.write('|chats:');
      for (final message in chatHistory.take(3)) {
        // Only use the last 3 messages
        buffer.write(
          '${message.isUser ? 'u' : 'a'}:${message.content.substring(0, min(20, message.content.length))}|',
        );
      }
    }

    if (existingItinerary != null) {
      buffer.write('|existing:${existingItinerary.title}|');
    }

    return buffer.toString().hashCode.toString();
  }

  // Clean expired cache entries
  void _cleanCache() {
    final now = DateTime.now();
    _responseCache.removeWhere(
      (key, value) => now.difference(value.timestamp) > _cacheTtl,
    );

    // If still too many items, remove oldest entries
    if (_responseCache.length > _maxCacheItems) {
      final sortedEntries = _responseCache.entries.toList()
        ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

      for (int i = 0; i < sortedEntries.length - _maxCacheItems; i++) {
        _responseCache.remove(sortedEntries[i].key);
      }
    }
  }

  Stream<Either<Failure, Map<String, dynamic>>> streamStructuredItinerary({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  }) async* {
    try {
      if (!AppEnvironmentConfig.isGroqConfigured) {
        yield Left(
          ConfigurationFailure(message: 'Groq API key is not configured'),
        );
        return;
      }

      final messages = _buildSystemPromptForStructuredItinerary(
        prompt,
        chatHistory,
        existingItinerary,
      );

      final request = http.Request(
        'POST',
        Uri.parse('$_baseUrl/chat/completions'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${AppEnvironmentConfig.groqApiKey}',
        'Content-Type': 'application/json',
      });

      request.body = jsonEncode({
        'model': _model,
        'messages': messages,
        'temperature': 0.2,
        'max_tokens': 4000,
        'stream': true,
      });

      final streamedResponse = await _client.send(request);

      if (streamedResponse.statusCode == 200) {
        String accumulatedContent = '';
        int promptTokens = 0;
        int completionTokens = 0;

        await for (final chunk in streamedResponse.stream.transform(
          utf8.decoder,
        )) {
          final lines = chunk.split('\n');

          for (final line in lines) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6);

              if (data == '[DONE]') {
                // Try to extract JSON from accumulated content
                final jsonMatch = RegExp(
                  r'\{[\s\S]*\}',
                ).firstMatch(accumulatedContent);
                if (jsonMatch != null) {
                  try {
                    final jsonContent = jsonMatch.group(0)!;
                    final itineraryData = jsonDecode(jsonContent);

                    yield Right({
                      'itinerary': itineraryData,
                      'usage': {
                        'prompt_tokens': promptTokens,
                        'completion_tokens': completionTokens,
                        'total_tokens': promptTokens + completionTokens,
                      },
                      'raw_response': accumulatedContent,
                      'is_final': true,
                    });
                  } catch (e) {
                    yield Left(
                      ParsingFailure(
                        message:
                            'Failed to parse JSON in final response: ${e.toString()}',
                      ),
                    );
                  }
                } else {
                  yield Left(
                    ParsingFailure(
                      message: 'No JSON found in the final response',
                    ),
                  );
                }
                break;
              }

              try {
                final json = jsonDecode(data);
                final delta = json['choices'][0]['delta'];

                if (delta['content'] != null) {
                  final content = delta['content'] as String;
                  accumulatedContent += content;
                  completionTokens += _estimateTokens(content);

                  // Yield partial content for UI updates
                  yield Right({
                    'partial_content': content,
                    'accumulated_content': accumulatedContent,
                    'is_final': false,
                  });
                }
              } catch (e) {
                // Skip invalid JSON chunks
                continue;
              }
            }
          }
        }
      } else if (streamedResponse.statusCode == 401) {
        yield Left(AuthenticationFailure(message: 'Invalid Groq API key'));
      } else if (streamedResponse.statusCode == 429) {
        yield Left(RateLimitFailure(message: 'Groq API rate limit exceeded'));
      } else {
        yield Left(
          NetworkFailure(
            message: 'Groq API error: ${streamedResponse.statusCode}',
          ),
        );
      }
    } catch (e) {
      yield Left(UnknownFailure(message: e.toString()));
    }
  }

  // Stream a human-readable itinerary for better UX
  Stream<Either<Failure, String>> streamHumanReadableItinerary({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  }) async* {
    try {
      if (!AppEnvironmentConfig.isGroqConfigured) {
        yield Left(
          ConfigurationFailure(message: 'Groq API key is not configured'),
        );
        return;
      }

      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content':
              '''You are an expert travel planner that creates practical, easy-to-read itineraries.
When a user asks you to plan a trip, respond with a clear, structured itinerary in this exact format:

Day X: [Brief title for the day]

• Morning: [Specific morning activity]
  [Brief detail about the activity if needed]
• Transfer: [Travel details with time estimates]
• Accommodation: [Specific hotel or lodging with brief description]
• Afternoon: [Specific afternoon activity]
  [Brief detail about the activity if needed]
• Evening: [Specific evening activity or dinner]
  [Brief detail about restaurants or venues]

Example format:
Day 1: Arrival in Bali & Settle in Ubud
• Morning: Arrive in Bali, Denpasar Airport.
• Transfer: Private driver to Ubud (around 1.5 hours).
• Accommodation: Check-in at a peaceful boutique hotel or villa in Ubud (e.g., Ubud Aura Retreat).
• Afternoon: Explore Ubud's local area, walk around the tranquil rice terraces at Tegallalang.
• Evening: Dinner at Locavore (known for farm-to-table dishes in peaceful environment)

Always include:
1. Specific locations that actually exist
2. Time estimates for transfers
3. Real hotel and restaurant names
4. Practical details about activities
5. Information organized by time of day

Keep it concise, practical, and easy to follow.''',
        },
      ];

      // Add existing itinerary if available
      if (existingItinerary != null) {
        final readableItinerary = _convertItineraryToReadableFormat(
          existingItinerary,
        );
        messages.add({'role': 'assistant', 'content': readableItinerary});
      }

      // Add chat history for context
      if (chatHistory != null && chatHistory.isNotEmpty) {
        for (final message in chatHistory) {
          messages.add({
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.content,
          });
        }
      }

      // Add current prompt
      messages.add({'role': 'user', 'content': prompt});

      final request = http.Request(
        'POST',
        Uri.parse('$_baseUrl/chat/completions'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer ${AppEnvironmentConfig.groqApiKey}',
        'Content-Type': 'application/json',
      });

      request.body = jsonEncode({
        'model': _model,
        'messages': messages,
        'temperature': 0.5,
        'max_tokens': 2000,
        'stream': true,
      });

      final streamedResponse = await _client.send(request);

      if (streamedResponse.statusCode == 200) {
        String accumulatedContent = '';

        await for (final chunk in streamedResponse.stream.transform(
          utf8.decoder,
        )) {
          final lines = chunk.split('\n');

          for (final line in lines) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6);

              if (data == '[DONE]') {
                yield Right(accumulatedContent);
                break;
              }

              try {
                final json = jsonDecode(data);
                final delta = json['choices'][0]['delta'];

                if (delta['content'] != null) {
                  final content = delta['content'] as String;
                  accumulatedContent += content;

                  // Stream each chunk as it arrives
                  yield Right(content);
                }
              } catch (e) {
                // Skip invalid JSON chunks
                continue;
              }
            }
          }
        }
      } else if (streamedResponse.statusCode == 401) {
        yield Left(AuthenticationFailure(message: 'Invalid Groq API key'));
      } else if (streamedResponse.statusCode == 429) {
        yield Left(RateLimitFailure(message: 'Groq API rate limit exceeded'));
      } else {
        yield Left(
          NetworkFailure(
            message: 'Groq API error: ${streamedResponse.statusCode}',
          ),
        );
      }
    } catch (e) {
      yield Left(UnknownFailure(message: e.toString()));
    }
  }

  // Helper method to estimate tokens in a string
  int _estimateTokens(String text) {
    // Simple estimation: roughly 4 characters per token
    return (text.length / 4).ceil();
  }

  // Extract travel details from prompt for display
  Future<Either<Failure, Map<String, String>>> extractTravelDetails({
    required String prompt,
  }) async {
    try {
      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content':
              '''You are a travel information extractor. Extract the origin city, destination city and country, 
and estimated travel time between them if mentioned in the user's prompt. 
Respond ONLY with a JSON object in this exact format:

{
  "origin": "Origin city name or null if not mentioned",
  "destination": "Destination city and country",
  "travelTime": "Estimated travel time in format: XXhrs XXmins or null if not mentioned"
}

For example, if the user wants to plan a trip from Mumbai to Bali, respond with:
{"origin": "Mumbai", "destination": "Bali, Indonesia", "travelTime": "11hrs 5mins"}

If no origin is mentioned, use null for that field.
If you can't determine travel time, use null for that field.
Only include the JSON object in your response, nothing else.''',
        },
        {'role': 'user', 'content': prompt},
      ];

      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${AppEnvironmentConfig.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.1,
          'max_tokens': 200,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // Extract JSON from response
        try {
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
          if (jsonMatch != null) {
            final jsonContent = jsonMatch.group(0)!;
            final travelData = jsonDecode(jsonContent) as Map<String, dynamic>;

            return Right({
              'origin': travelData['origin'] as String? ?? '',
              'destination': travelData['destination'] as String? ?? '',
              'travelTime': travelData['travelTime'] as String? ?? '',
            });
          }

          // Fallback if no JSON match
          return Right({'origin': '', 'destination': '', 'travelTime': ''});
        } catch (e) {
          return Right({'origin': '', 'destination': '', 'travelTime': ''});
        }
      } else {
        return Right({'origin': '', 'destination': '', 'travelTime': ''});
      }
    } catch (e) {
      return Right({'origin': '', 'destination': '', 'travelTime': ''});
    }
  }

  // For backward compatibility with original API
  Future<Either<Failure, String>> generateItinerary({
    required String prompt,
    List<Map<String, dynamic>>? chatHistory,
    Map<String, dynamic>? existingItinerary,
  }) async {
    try {
      // Convert chat history to the new format
      final List<ChatMessage> convertedChatHistory =
          chatHistory
              ?.map(
                (msg) => ChatMessage(
                  content: msg['content'] as String,
                  isUser: msg['isUser'] as bool,
                  timestamp: DateTime.now(),
                ),
              )
              .toList() ??
          [];

      // Convert existing itinerary if provided
      Itinerary? convertedItinerary;
      if (existingItinerary != null) {
        try {
          // Simplified conversion - in a real app you'd use your model class
          convertedItinerary = Itinerary(
            title: existingItinerary['title'] as String? ?? 'Trip Plan',
            startDate:
                existingItinerary['startDate'] as String? ??
                DateTime.now().toIso8601String().split('T').first,
            endDate:
                existingItinerary['endDate'] as String? ??
                DateTime.now()
                    .add(const Duration(days: 3))
                    .toIso8601String()
                    .split('T')
                    .first,
            totalCost: existingItinerary['totalCost'] as double?,
            currency: existingItinerary['currency'] as String?,
            days: const [], // Simplified for compatibility
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        } catch (e) {
          // Ignore conversion errors
        }
      }

      // Use the human readable format for better UX
      final result = await generateHumanReadableItinerary(
        prompt: prompt,
        chatHistory: convertedChatHistory,
        existingItinerary: convertedItinerary,
      );

      return result;
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // For backward compatibility with original API
  Stream<Either<Failure, String>> streamItinerary({
    required String prompt,
    List<Map<String, dynamic>>? chatHistory,
    Map<String, dynamic>? existingItinerary,
  }) async* {
    try {
      // Convert chat history to the new format
      final List<ChatMessage> convertedChatHistory =
          chatHistory
              ?.map(
                (msg) => ChatMessage(
                  content: msg['content'] as String,
                  isUser: msg['isUser'] as bool,
                  timestamp: DateTime.now(),
                ),
              )
              .toList() ??
          [];

      // Convert existing itinerary if provided
      Itinerary? convertedItinerary;
      if (existingItinerary != null) {
        try {
          // Simplified conversion - in a real app you'd use your model class
          convertedItinerary = Itinerary(
            title: existingItinerary['title'] as String? ?? 'Trip Plan',
            startDate:
                existingItinerary['startDate'] as String? ??
                DateTime.now().toIso8601String().split('T').first,
            endDate:
                existingItinerary['endDate'] as String? ??
                DateTime.now()
                    .add(const Duration(days: 3))
                    .toIso8601String()
                    .split('T')
                    .first,
            totalCost: existingItinerary['totalCost'] as double?,
            currency: existingItinerary['currency'] as String?,
            days: const [], // Simplified for compatibility
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        } catch (e) {
          // Ignore conversion errors
        }
      }

      // Use the human readable streaming format
      yield* streamHumanReadableItinerary(
        prompt: prompt,
        chatHistory: convertedChatHistory,
        existingItinerary: convertedItinerary,
      );
    } catch (e) {
      yield Left(UnknownFailure(message: e.toString()));
    }
  }

  List<Map<String, dynamic>> _buildSystemPromptForStructuredItinerary(
    String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  ) {
    final messages = <Map<String, dynamic>>[];

    // Detailed system prompt for structured JSON output optimized for the UI display
    messages.add({
      'role': 'system',
      'content':
          '''You are an expert travel planner that creates detailed itineraries.
When a user asks you to plan a trip, respond with a JSON object in the following format:

```json
{
  "title": "Trip to [Destination]",
  "startDate": "YYYY-MM-DD",
  "endDate": "YYYY-MM-DD",
  "origin": "User's origin city if mentioned, otherwise null",
  "destination": "Destination city and country",
  "travelTime": "Estimated travel time in format: XXhrs XXmins",
  "days": [
    {
      "date": "YYYY-MM-DD",
      "summary": "Day X: Main activity or theme for the day",
      "items": [
        {
          "timeOfDay": "Morning|Transfer|Accommodation|Afternoon|Evening",
          "activity": "Specific activity with concrete details",
          "location": "Exact location name",
          "description": "Practical details about the activity (1-2 sentences)",
          "estimatedCost": 25.0,
          "category": "breakfast|lunch|dinner|sightseeing|transportation|accommodation",
          "coordinates": "Latitude,Longitude if available, otherwise null",
          "duration": "Estimated duration in hours, optional"
        }
      ]
    }
  ],
  "totalCost": 1250.0,
  "currency": "USD",
  "travelTips": ["2-3 specific tips related to the destination", "...]
}
```

Guidelines:
1. Format day summaries as "Day X: Activity Theme" (Example: "Day 1: Arrival in Bali & Settle in Ubud")
2. For each activity timeOfDay, use exactly one of: "Morning", "Transfer", "Accommodation", "Afternoon" or "Evening"
3. Activities should be concrete and specific (Example: "Arrive in Bali, Denpasar Airport")
4. Include transfer details between locations with estimated times (Example: "Private driver to Ubud (around 1.5 hours)")
5. Mention specific accommodation options with brief descriptions
6. Include real restaurant names for meals with a brief note about cuisine
7. All locations must be real places that actually exist in the destination
8. Focus on practical, actionable information rather than general descriptions

Remember to format the output ONLY as valid JSON. Include nothing else in your response except the JSON object.''',
    });

    // Add existing itinerary if available
    if (existingItinerary != null) {
      messages.add({
        'role': 'assistant',
        'content': jsonEncode(existingItinerary),
      });
    }

    // Add chat history for context
    if (chatHistory != null && chatHistory.isNotEmpty) {
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

  // Function for web search refinement
  Future<Either<Failure, String>> refineWithWebSearch({
    required String prompt,
    required List<String> searchTerms,
  }) async {
    try {
      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content':
              '''You are an expert travel planner with access to real-time information. 
Based on the search results provided, answer the user's query with accurate, up-to-date information.
Include specific details from the search results like opening hours, prices, reviews, and recommendations.
Always prioritize factual information from the search results over general knowledge.''',
        },
        {
          'role': 'user',
          'content':
              '''Here are search results for relevant information:

$searchTerms

Based on this information, please provide a detailed answer to my query: $prompt''',
        },
      ];

      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${AppEnvironmentConfig.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.3,
          'max_tokens': 1000,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return Right(content);
      } else if (response.statusCode == 401) {
        return Left(AuthenticationFailure(message: 'Invalid Groq API key'));
      } else {
        return Left(
          NetworkFailure(message: 'Groq API error: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // General text completion for follow-up questions
  Future<Either<Failure, String>> generateTextResponse({
    required String prompt,
    List<ChatMessage>? chatHistory,
  }) async {
    try {
      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content':
              '''You are an expert travel assistant helping users plan their trips.
Provide helpful, informative responses to travel-related questions.
When users ask about specific destinations, offer practical advice about accommodation, transportation, attractions, and local customs.
Keep responses concise, specific, and actionable.''',
        },
      ];

      // Add chat history for context
      if (chatHistory != null && chatHistory.isNotEmpty) {
        for (final message in chatHistory) {
          messages.add({
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.content,
          });
        }
      }

      // Add current prompt
      messages.add({'role': 'user', 'content': prompt});

      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${AppEnvironmentConfig.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1000,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return Right(content);
      } else {
        return Left(
          NetworkFailure(message: 'API error: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Generate a human-readable itinerary in the format shown in the UI
  Future<Either<Failure, String>> generateHumanReadableItinerary({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  }) async {
    try {
      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content':
              '''You are an expert travel planner that creates practical, easy-to-read itineraries.
When a user asks you to plan a trip, respond with a clear, structured itinerary in this exact format:

Day X: [Brief title for the day]

• Morning: [Specific morning activity]
  [Brief detail about the activity if needed]
• Transfer: [Travel details with time estimates]
• Accommodation: [Specific hotel or lodging with brief description]
• Afternoon: [Specific afternoon activity]
  [Brief detail about the activity if needed]
• Evening: [Specific evening activity or dinner]
  [Brief detail about restaurants or venues]

Example format:
Day 1: Arrival in Bali & Settle in Ubud
• Morning: Arrive in Bali, Denpasar Airport.
• Transfer: Private driver to Ubud (around 1.5 hours).
• Accommodation: Check-in at a peaceful boutique hotel or villa in Ubud (e.g., Ubud Aura Retreat).
• Afternoon: Explore Ubud's local area, walk around the tranquil rice terraces at Tegallalang.
• Evening: Dinner at Locavore (known for farm-to-table dishes in peaceful environment)

Always include:
1. Specific locations that actually exist
2. Time estimates for transfers
3. Real hotel and restaurant names
4. Practical details about activities
5. Information organized by time of day

Keep it concise, practical, and easy to follow.''',
        },
      ];

      // Add existing itinerary if available
      if (existingItinerary != null) {
        final readableItinerary = _convertItineraryToReadableFormat(
          existingItinerary,
        );
        messages.add({'role': 'assistant', 'content': readableItinerary});
      }

      // Add chat history for context
      if (chatHistory != null && chatHistory.isNotEmpty) {
        for (final message in chatHistory) {
          messages.add({
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.content,
          });
        }
      }

      // Add current prompt
      messages.add({'role': 'user', 'content': prompt});

      final response = await _client.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer ${AppEnvironmentConfig.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.5,
          'max_tokens': 2000,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return Right(content);
      } else if (response.statusCode == 401) {
        return Left(AuthenticationFailure(message: 'Invalid Groq API key'));
      } else if (response.statusCode == 429) {
        return Left(RateLimitFailure(message: 'Groq API rate limit exceeded'));
      } else {
        return Left(
          NetworkFailure(message: 'Groq API error: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Helper to convert an Itinerary entity to human-readable format
  String _convertItineraryToReadableFormat(Itinerary itinerary) {
    final buffer = StringBuffer();

    for (final day in itinerary.days) {
      buffer.writeln(day.summary);

      for (final item in day.items) {
        final timeOfDay = _determineTimeOfDay(item.time);
        buffer.writeln('• $timeOfDay: ${item.activity}');
        if (item.description != null && item.description!.isNotEmpty) {
          buffer.writeln('  ${item.description}');
        }
      }

      buffer.writeln();
    }

    return buffer.toString();
  }

  String _determineTimeOfDay(String? time) {
    if (time == null) return "Activity";

    // Check for keywords first
    if (time.toLowerCase().contains('morning')) return 'Morning';
    if (time.toLowerCase().contains('afternoon')) return 'Afternoon';
    if (time.toLowerCase().contains('evening')) return 'Evening';
    if (time.toLowerCase().contains('transfer')) return 'Transfer';
    if (time.toLowerCase().contains('accommodation')) return 'Accommodation';

    // Try to parse time if it's in a time format
    try {
      final hour = int.parse(time.split(':')[0]);
      if (hour < 12) return 'Morning';
      if (hour < 17) return 'Afternoon';
      return 'Evening';
    } catch (e) {
      return 'Activity'; // Default fallback
    }
  }
}
