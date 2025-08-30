import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

import '../../core/config/environment_config.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_service_repository.dart';

import 'ai_service.dart';
import 'web_search_service.dart';

class EnhancedAIService implements AIServiceRepository {
  final WebSearchService _webSearchService;

  EnhancedAIService({WebSearchService? webSearchService})
    : _webSearchService = webSearchService ?? WebSearchService();

  @override
  Future<Either<Failure, Itinerary>> generateItinerary({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  }) async {
    final searchResult = await _webSearchService.performSearch(
      prompt,
      'general',
    );
    return searchResult.fold((failure) => Left(failure), (results) {
      final day = ItineraryDay(
        date: DateTime.now().toIso8601String().split('T').first,
        summary: 'Search Results',
        items: results
            .map(
              (r) => ItineraryItem(
                time: '',
                activity: r.title,
                location: r.displayLink,
                description: r.snippet,
                estimatedCost: null,
                category: r.category,
              ),
            )
            .toList(),
      );
      final itinerary = Itinerary(
        title: prompt,
        startDate: day.date,
        endDate: day.date,
        totalCost: null,
        currency: '',
        days: [day],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return Right(itinerary);
    });
  }

  @override
  Future<Either<Failure, String>> refineItinerary({
    required String prompt,
    required Itinerary currentItinerary,
    required List<ChatMessage> chatHistory,
  }) async {
    return Right('Refinement is not supported with Google Search.');
  }

  @override
  Stream<Either<Failure, String>> streamResponse({
    required String prompt,
    List<ChatMessage>? chatHistory,
    Itinerary? existingItinerary,
  }) async* {
    yield* Stream.value(
      Right('Streaming is not supported with Google Search.'),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> searchWebInformation({
    required String query,
    String? location,
    String? dateRange,
  }) async {
    final searchResult = await _webSearchService.performSearch(
      query,
      'general',
    );
    return searchResult.fold(
      (failure) => Left(failure),
      (results) => Right({
        'results': results.map((r) => r.toJson()).toList(),
        'query': query,
      }),
    );
  }
}
