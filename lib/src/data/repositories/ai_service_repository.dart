import 'dart:convert';
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_service_repository.dart';
import '../services/groq_service.dart';
import '../services/web_search_service.dart';
import '../services/token_usage_service.dart';
import '../models/itinerary_model_helper.dart';

class AIServiceRepositoryImpl implements AIServiceRepository {
  final GroqService _groqService;
  final WebSearchService _webSearchService;
  final TokenUsageService _tokenUsageService;

  AIServiceRepositoryImpl({
    required GroqService groqService,
    required WebSearchService webSearchService,
    required TokenUsageService tokenUsageService,
  }) : _groqService = groqService,
       _webSearchService = webSearchService,
       _tokenUsageService = tokenUsageService;

  @override
  Future<Either<Failure, Itinerary>> generateItinerary({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  }) async {
    try {
      print('DEBUG: Starting generateItinerary with prompt: $prompt');

      // Generate search queries based on the prompt
      final searchQueries = _generateSearchQueriesFromPrompt(prompt);
      print('DEBUG: Generated search queries: $searchQueries');

      // Perform web searches
      final searchResults = <String>[];
      for (final query in searchQueries) {
        print('DEBUG: Performing search for query: $query');
        final result = await _webSearchService.searchWithFallback(query);
        result.fold(
          (failure) {
            // Log the failure but continue
            print('Search failed for query "$query": ${failure.message}');
          },
          (results) {
            // Extract useful information from search results
            print(
              'DEBUG: Got ${results.length} search results for query: $query',
            );
            if (results.isNotEmpty) {
              final snippets = results
                  .map((result) => '${result['title']}: ${result['snippet']}')
                  .join('\n');
              searchResults.add('Query: $query\nResults:\n$snippets\n');
            }
          },
        );
      }

      // Generate itinerary with LLM using search results for context
      print(
        'DEBUG: Calling Groq service with search results: ${searchResults.length}',
      );
      final response = await _groqService.generateStructuredItinerary(
        prompt: _buildPromptWithSearchResults(prompt, searchResults),
        chatHistory: chatHistory,
        existingItinerary: existingItinerary,
      );

      return response.fold(
        (failure) {
          print('DEBUG: Groq service returned a failure: ${failure.message}');
          return Left(failure);
        },
        (data) async {
          print('DEBUG: Groq service returned data: ${data.runtimeType}');

          // Track token usage
          final usage = data['usage'];
          if (usage != null) {
            print(
              'DEBUG: Token usage - prompt: ${usage['prompt_tokens']}, completion: ${usage['completion_tokens']}',
            );
            await _tokenUsageService.trackUsage(
              promptTokens: usage['prompt_tokens'],
              completionTokens: usage['completion_tokens'],
              model: 'gemma2-9b-it',
            );
          } else {
            print('DEBUG: No usage data returned from Groq service');
          }

          // Parse itinerary data
          final itineraryData = data['itinerary'];
          if (itineraryData == null) {
            print('DEBUG: No itinerary data found in API response');
            return Left(
              ParsingFailure(
                message: 'No itinerary data found in API response',
              ),
            );
          }
          print('DEBUG: Itinerary data type: ${itineraryData.runtimeType}');
          print('DEBUG: Itinerary data: $itineraryData');

          try {
            // Convert raw data to Itinerary model with safe parsing helper
            print(
              'DEBUG: Attempting to convert data to ItineraryModel with safe parsing',
            );

            // Use the helper class to safely parse the data
            final itineraryModel = ItineraryModelHelper.safeFromJson(
              itineraryData,
            );
            print(
              'DEBUG: Successfully converted to ItineraryModel: ${itineraryModel.toString()}',
            );
            return Right(itineraryModel.toEntity());
          } catch (e, stackTrace) {
            print('DEBUG: Error parsing itinerary data: $e');
            print('DEBUG: Error stack trace: $stackTrace');
            print('DEBUG: Data that caused error: $itineraryData');
            return Left(
              ParsingFailure(message: 'Failed to parse itinerary data: $e'),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      print('DEBUG: Exception in generateItinerary: $e');
      print('DEBUG: Exception stack trace: $stackTrace');
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
      // Generate search queries based on the refinement prompt
      final searchQueries = _generateSearchQueriesFromPrompt(prompt);

      // Perform web searches
      final searchResults = <String>[];
      for (final query in searchQueries) {
        final result = await _webSearchService.searchWithFallback(query);
        result.fold(
          (failure) {
            // Log the failure but continue
            print('Search failed for query "$query": ${failure.message}');
          },
          (results) {
            // Extract useful information from search results
            if (results.isNotEmpty) {
              final snippets = results
                  .map((result) => '${result['title']}: ${result['snippet']}')
                  .join('\n');
              searchResults.add('Query: $query\nResults:\n$snippets\n');
            }
          },
        );
      }

      // Use the text completion API to generate a response
      return _groqService.generateTextResponse(
        prompt: _buildPromptWithSearchResults(
          'Refine this itinerary: ${jsonEncode(currentItinerary)}\n\nRefinement request: $prompt',
          searchResults,
        ),
        chatHistory: chatHistory,
      );
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
      // Generate search queries based on the prompt
      final searchQueries = _generateSearchQueriesFromPrompt(prompt);

      // Perform web searches in parallel
      final searchResults = <String>[];
      final searchFutures = <Future<void>>[];

      for (final query in searchQueries) {
        searchFutures.add(
          _webSearchService.searchWithFallback(query).then((result) {
            result.fold(
              (failure) {
                // Log the failure but continue
                print('Search failed for query "$query": ${failure.message}');
              },
              (results) {
                // Extract useful information from search results
                if (results.isNotEmpty) {
                  final snippets = results
                      .map(
                        (result) => '${result['title']}: ${result['snippet']}',
                      )
                      .join('\n');
                  searchResults.add('Query: $query\nResults:\n$snippets\n');
                }
              },
            );
          }),
        );
      }

      // Wait for all searches to complete
      await Future.wait(searchFutures);

      // Stream the response from the LLM
      final promptWithSearch = _buildPromptWithSearchResults(
        prompt,
        searchResults,
      );
      await for (final chunk in _groqService.streamStructuredItinerary(
        prompt: promptWithSearch,
        chatHistory: chatHistory,
        existingItinerary: existingItinerary,
      )) {
        yield chunk.fold((failure) => Left(failure), (data) {
          // Track token usage when final response is received
          if (data['is_final'] == true && data['usage'] != null) {
            final usage = data['usage'];
            _tokenUsageService.trackUsage(
              promptTokens: usage['prompt_tokens'],
              completionTokens: usage['completion_tokens'],
              model: 'gemma2-9b-it',
            );
          }

          // Return partial content for intermediate chunks
          if (data['partial_content'] != null) {
            return Right(data['partial_content']);
          }

          return Right('');
        });
      }
    } catch (e) {
      yield Left(UnknownFailure(message: e.toString()));
    }
  }

  // Helper methods

  List<String> _generateSearchQueriesFromPrompt(String prompt) {
    final queries = <String>[];

    // Extract destination
    final destinationMatch = RegExp(
      r'(?:in|to|at)\s+([A-Za-z\s]+)(?:,|\s|for|next|\.|\?|$)',
    ).firstMatch(prompt);
    if (destinationMatch != null) {
      final destination = destinationMatch.group(1)?.trim();
      if (destination != null && destination.isNotEmpty) {
        queries.add('Top attractions in $destination');
        queries.add('Best restaurants in $destination');
        queries.add('Weather in $destination');
      }
    }

    // Extract activities or interests
    final keywords = [
      'museum',
      'beach',
      'hiking',
      'food',
      'history',
      'art',
      'shopping',
      'nightlife',
      'family',
      'adventure',
      'luxury',
      'budget',
    ];

    for (final keyword in keywords) {
      if (prompt.toLowerCase().contains(keyword)) {
        final destination = destinationMatch?.group(1)?.trim() ?? '';
        if (destination.isNotEmpty) {
          queries.add('Best $keyword in $destination');
        }
      }
    }

    // If we couldn't extract specific queries, use the whole prompt
    if (queries.isEmpty) {
      queries.add('Travel information for $prompt');
    }

    // Limit to 3 queries
    return queries.take(3).toList();
  }

  String _buildPromptWithSearchResults(
    String prompt,
    List<String> searchResults,
  ) {
    if (searchResults.isEmpty) {
      return prompt;
    }

    return '''
$prompt

Based on the following real-time information:
${searchResults.join('\n\n')}
''';
  }
}
