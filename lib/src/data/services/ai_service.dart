import 'dart:async';
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_service_repository.dart';

import 'web_search_service.dart';
import 'groq_service.dart';

class _ParsedPrompt {
  final String title;
  final String? location;
  final int days;
  final DateTime startDate;

  _ParsedPrompt({
    required this.title,
    required this.location,
    required this.days,
    required this.startDate,
  });
}

_ParsedPrompt _parsePrompt(String prompt) {
  // Very lightweight heuristic parser to extract location and days
  final lower = prompt.toLowerCase();
  final daysMatch = RegExp(r'(\d+)\s*(day|days)').firstMatch(lower);
  final int days = int.tryParse(daysMatch?.group(1) ?? '') ?? 3;

  String? location;
  // naive: pick last word group after 'in'
  final inMatch = RegExp(r'in\s+([a-zA-Z\s,]+)').firstMatch(prompt);
  if (inMatch != null) {
    location = inMatch.group(1)?.trim();
    if (location != null) {
      // trim trailing punctuation
      location = location.replaceAll(RegExp(r'[\.!]$'), '').trim();
    }
  }

  final startDate = DateTime.now();
  final title = prompt.trim().isEmpty
      ? 'Trip Plan'
      : '$days-Day Trip${location != null ? ' in $location' : ''}';

  return _ParsedPrompt(
    title: title,
    location: location,
    days: days.clamp(1, 30),
    startDate: startDate,
  );
}

String? _getLocationCoordinates(
  String? location,
  String timeOfDay,
  int dayIndex,
) {
  // For now we'll return null instead of hardcoded coordinates
  // In a real implementation, this would use a geocoding service API
  if (location == null) return null;

  // Return null as placeholder - would be replaced with actual API call
  return null;
}

class AIService implements AIServiceRepository {
  // Performance optimization: simple caching system

  final WebSearchService _webSearchService;
  final GroqService _groqService;

  AIService({WebSearchService? webSearchService, GroqService? groqService})
    : _webSearchService = webSearchService ?? WebSearchService(),
      _groqService = groqService ?? GroqService();

  @override
  Future<Either<Failure, Itinerary>> generateItinerary({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  }) async {
    try {
      final _ParsedPrompt parsed = _parsePrompt(prompt);

      // Convert chat history to Groq format
      final groqChatHistory = chatHistory
          ?.map((msg) => {'isUser': msg.isUser, 'content': msg.content})
          .toList();

      // First try to generate a structured itinerary using the new method
      final structuredResult = await _groqService.generateStructuredItinerary(
        prompt: prompt,
        chatHistory: chatHistory,
        existingItinerary: existingItinerary,
        useCache: true,
      );

      return structuredResult.fold(
        (failure) async {
          // Fall back to the older text-based approach if structured fails
          final groqResult = await _groqService.generateItinerary(
            prompt: prompt,
            chatHistory: groqChatHistory,
            existingItinerary: existingItinerary?.toJson(),
          );

          return groqResult.fold((failure) => Left(failure), (response) async {
            // Parse the Groq response into structured itinerary
            final itinerary = _parseGroqResponse(response, parsed);

            // Optionally enrich with Google Search results
            if (parsed.location != null && parsed.location!.isNotEmpty) {
              final enrichedItinerary = await _enrichWithSearchResults(
                itinerary,
                parsed.location!,
              );
              return Right(enrichedItinerary);
            }
            return Right(itinerary);
          });
        },
        (structuredData) async {
          // Use the structured data directly
          // This would require a new method to convert the structured JSON to Itinerary
          final itinerary = _createItineraryFromStructuredData(
            structuredData,
            parsed,
          );

          // Optionally enrich with Google Search results
          if (parsed.location != null && parsed.location!.isNotEmpty) {
            final enrichedItinerary = await _enrichWithSearchResults(
              itinerary,
              parsed.location!,
            );
            return Right(enrichedItinerary);
          }
          return Right(itinerary);
        },
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Itinerary _parseGroqResponse(String response, _ParsedPrompt parsed) {
    // Parse the Groq response and extract structured data
    final lines = response.split('\n');
    final List<ItineraryDay> days = [];

    String currentDaySummary = '';
    final List<ItineraryItem> currentItems = [];
    int dayIndex = 0;

    for (final line in lines) {
      final trimmedLine = line.trim();

      // Check for day headers
      if (trimmedLine.startsWith('**Day') && trimmedLine.contains(':**')) {
        // Save previous day if exists
        if (currentDaySummary.isNotEmpty && currentItems.isNotEmpty) {
          days.add(
            ItineraryDay(
              date: parsed.startDate
                  .add(Duration(days: dayIndex))
                  .toIso8601String()
                  .split('T')
                  .first,
              summary: currentDaySummary,
              items: List.from(currentItems),
            ),
          );
          currentItems.clear();
          dayIndex++;
        }

        // Extract day summary
        currentDaySummary = trimmedLine
            .replaceAll('**', '')
            .replaceAll('Day ${dayIndex + 1}:', '')
            .trim();
      }
      // Check for activity sections
      else if (trimmedLine.startsWith('**Morning:**') ||
          trimmedLine.startsWith('**Transfer:**') ||
          trimmedLine.startsWith('**Accommodation:**') ||
          trimmedLine.startsWith('**Afternoon:**') ||
          trimmedLine.startsWith('**Evening:**')) {
        final section = trimmedLine.split(':**')[0].replaceAll('**', '');
        final content = trimmedLine.split(':**')[1].trim();

        currentItems.add(
          ItineraryItem(
            time: _getTimeForSection(section),
            activity: content,
            location: _getLocationCoordinates(
              parsed.location,
              section.toLowerCase(),
              dayIndex,
            ),
            description: _getDescriptionForSection(section),
          ),
        );
      }
    }

    // Add the last day
    if (currentDaySummary.isNotEmpty && currentItems.isNotEmpty) {
      days.add(
        ItineraryDay(
          date: parsed.startDate
              .add(Duration(days: dayIndex))
              .toIso8601String()
              .split('T')
              .first,
          summary: currentDaySummary,
          items: List.from(currentItems),
        ),
      );
    }

    // If no days were parsed, create a fallback
    if (days.isEmpty) {
      final date = parsed.startDate.toIso8601String().split('T').first;
      final daySummary = 'Day 1: ${parsed.title}';

      days.add(
        ItineraryDay(
          date: date,
          summary: daySummary,
          items: [
            ItineraryItem(
              time: _getTimeForSection('morning'),
              activity: 'Start your journey',
              location: _getLocationCoordinates(parsed.location, 'morning', 0),
              description: _getDescriptionForSection('morning'),
            ),
          ],
        ),
      );
    }
    return Itinerary(
      title: parsed.title,
      startDate: days.first.date,
      endDate: days.last.date,
      totalCost: null,
      currency: null,
      days: days,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String _getTimeForSection(String section) {
    // We could replace this with a configuration from a settings file
    // or a database lookup in a real app
    // For now we'll return sensible defaults based on the section
    final defaultTimes = {
      'morning': '09:00',
      'transfer': '11:00',
      'accommodation': '12:00',
      'afternoon': '14:00',
      'evening': '19:00',
    };

    return defaultTimes[section.toLowerCase()] ?? '10:00';
  }

  String? _getDescriptionForSection(String section) {
    // These descriptions could come from a translation file or database
    // to support internationalization
    final defaultDescriptions = {
      'morning': 'Start your day with this activity',
      'transfer': 'Travel to your next destination',
      'accommodation': 'Check into your accommodation',
      'afternoon': 'Continue exploring in the afternoon',
      'evening': 'End your day with this experience',
    };

    return defaultDescriptions[section.toLowerCase()];
  }

  Future<Itinerary> _enrichWithSearchResults(
    Itinerary itinerary,
    String location,
  ) async {
    try {
      // Use the search method available in WebSearchService
      final searchQuery =
          '$location travel guide ${itinerary.startDate} to ${itinerary.endDate}';
      final searchResult = await _webSearchService.search(searchQuery);

      return searchResult.fold(
        (failure) => itinerary, // Return original if search fails
        (results) {
          // For now, just return the original itinerary
          // In the future, we could use search results to enhance descriptions
          return itinerary;
        },
      );
    } catch (e) {
      return itinerary; // Return original if enrichment fails
    }
  }

  @override
  Future<Either<Failure, String>> refineItinerary({
    required String prompt,
    required Itinerary currentItinerary,
    required List<ChatMessage> chatHistory,
  }) async {
    try {
      // Convert chat history to Groq format
      final groqChatHistory = chatHistory
          .map((msg) => {'isUser': msg.isUser, 'content': msg.content})
          .toList();

      // Create a refinement prompt that includes the current itinerary
      final refinementPrompt =
          '''
Current itinerary: ${_formatItineraryForResponse(currentItinerary)}

User request: $prompt

Please refine the itinerary based on the user's request. If they want to add something, include it in the appropriate day. If they want to remove something, exclude it. If they want to change something, modify it accordingly.

Respond with the updated itinerary in the same format:
**Day X: [Day Summary]**
**Morning:** [Morning activity]
**Transfer:** [Travel details if applicable]
**Accommodation:** [Hotel details if applicable]
**Afternoon:** [Afternoon activity]
**Evening:** [Evening activity]
''';

      // Try using the new human-readable approach first
      final humanReadableResult = await _groqService
          .generateHumanReadableItinerary(
            prompt: refinementPrompt,
            chatHistory: chatHistory,
            existingItinerary: currentItinerary,
          );

      return humanReadableResult.fold((failure) async {
        // Fall back to older method if new one fails
        final groqResult = await _groqService.generateItinerary(
          prompt: refinementPrompt,
          chatHistory: groqChatHistory,
          existingItinerary: currentItinerary.toJson(),
        );

        return groqResult.fold(
          (failure) => Left(failure),
          (response) => Right(response),
        );
      }, (response) => Right(response));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  String _formatItineraryForResponse(Itinerary itinerary) {
    final buffer = StringBuffer();
    buffer.writeln('**${itinerary.title}**\n');

    for (final day in itinerary.days) {
      buffer.writeln('**${day.summary}**');
      for (final item in day.items) {
        buffer.writeln('• ${item.time}: ${item.activity}');
        if (item.description != null) {
          buffer.writeln('  ${item.description}');
        }
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  // Create an itinerary from structured JSON data returned by the groq service
  Itinerary _createItineraryFromStructuredData(
    Map<String, dynamic> data,
    _ParsedPrompt parsed,
  ) {
    try {
      // Extract basic itinerary info
      final String title = data['title'] ?? parsed.title;
      final dynamic totalCost = data['totalCost'];
      final String? currency = data['currency'];

      // Extract days data
      final List<dynamic> daysData = data['days'] ?? [];
      final List<ItineraryDay> days = [];

      if (daysData.isNotEmpty) {
        for (int i = 0; i < daysData.length; i++) {
          final dayData = daysData[i];
          final String summary =
              dayData['summary'] ?? 'Day ${i + 1}: Exploration';
          final String date =
              dayData['date'] ??
              parsed.startDate
                  .add(Duration(days: i))
                  .toIso8601String()
                  .split('T')
                  .first;

          // Extract items for this day
          final List<dynamic> itemsData = dayData['items'] ?? [];
          final List<ItineraryItem> items = [];

          for (final itemData in itemsData) {
            final String time = itemData['time'] ?? '';
            final String activity = itemData['activity'] ?? '';
            final String? location = itemData['location'];
            final String? description = itemData['description'];

            items.add(
              ItineraryItem(
                time: time,
                activity: activity,
                location: location,
                description: description,
              ),
            );
          }

          days.add(ItineraryDay(date: date, summary: summary, items: items));
        }
      }

      // If no days were parsed, create a fallback day
      if (days.isEmpty) {
        final date = parsed.startDate.toIso8601String().split('T').first;
        final daySummary = 'Day 1: ${parsed.title}';

        days.add(
          ItineraryDay(
            date: date,
            summary: daySummary,
            items: [
              ItineraryItem(
                time: _getTimeForSection('morning'),
                activity: 'Start your journey',
                location: _getLocationCoordinates(
                  parsed.location,
                  'morning',
                  0,
                ),
                description: _getDescriptionForSection('morning'),
              ),
            ],
          ),
        );
      }

      return Itinerary(
        title: title,
        startDate: days.first.date,
        endDate: days.last.date,
        totalCost: totalCost,
        currency: currency,
        days: days,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      // Fallback if parsing fails
      final startDate = parsed.startDate.toIso8601String().split('T').first;
      final endDate = parsed.startDate
          .add(Duration(days: parsed.days - 1))
          .toIso8601String()
          .split('T')
          .first;
      final daySummary = 'Day 1: ${parsed.title}';

      return Itinerary(
        title: parsed.title,
        startDate: startDate,
        endDate: endDate,
        days: [
          ItineraryDay(
            date: startDate,
            summary: daySummary,
            items: [
              ItineraryItem(
                time: _getTimeForSection('morning'),
                activity: 'Start your journey',
                location: _getLocationCoordinates(
                  parsed.location,
                  'morning',
                  0,
                ),
                description: _getDescriptionForSection('morning'),
              ),
            ],
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Stream<Either<Failure, String>> streamResponse({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  }) async* {
    try {
      // Convert chat history to Groq format
      final groqChatHistory = chatHistory
          ?.map((msg) => {'isUser': msg.isUser, 'content': msg.content})
          .toList();

      // First try to use the human-readable streaming approach
      try {
        yield* _groqService.streamHumanReadableItinerary(
          prompt: prompt,
          chatHistory: chatHistory,
          existingItinerary: existingItinerary,
        );
        return;
      } catch (e) {
        // Fall back to the older streaming method if the new one fails
        yield* _groqService.streamItinerary(
          prompt: prompt,
          chatHistory: groqChatHistory,
          existingItinerary: existingItinerary?.toJson(),
        );
      }
    } catch (e) {
      yield Left(UnknownFailure(message: e.toString()));
    }
  }

  // Method to search web information
  Future<Either<Failure, Map<String, dynamic>>> searchWebInformation({
    required String query,
    String? location,
    String? dateRange,
  }) async {
    // Build a complete search query incorporating all parameters
    String searchQuery = query;
    if (location != null && location.isNotEmpty) {
      searchQuery += ' $location';
    }
    if (dateRange != null && dateRange.isNotEmpty) {
      searchQuery += ' $dateRange';
    }

    // Use the search method from WebSearchService
    final searchResult = await _webSearchService.searchWithFallback(
      searchQuery,
    );

    return searchResult.fold((failure) => Left(failure), (results) {
      return Right({
        'results': results,
        'query': query,
        'location': location,
        'dateRange': dateRange,
      });
    });
  }
}
