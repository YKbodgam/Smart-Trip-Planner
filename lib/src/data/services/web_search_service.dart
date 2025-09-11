import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/error/failures.dart';

class WebSearchService {
  static const String _googleSearchBaseUrl = 'https://serpapi.com/search';

  final http.Client _client;

  WebSearchService({http.Client? client}) : _client = client ?? http.Client();

  // Get API key from .env file
  String? get _apiKey => dotenv.env['SERP_API_KEY'];

  // Check if service is configured
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  // Search for web information
  Future<Either<Failure, List<Map<String, dynamic>>>> search(
    String query,
  ) async {
    if (!isConfigured) {
      return Left(
        ConfigurationFailure(message: 'WebSearch API key is not configured'),
      );
    }

    try {
      final uri = Uri.parse(_googleSearchBaseUrl).replace(
        queryParameters: {
          'api_key': _apiKey,
          'q': query,
          'engine': 'google',
          'hl': 'en',
          'gl': 'us',
          'num': '5', // Limit to 5 results for cost-efficiency
        },
      );

      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Extract organic search results
        final organicResults = jsonData['organic_results'] as List<dynamic>?;
        if (organicResults == null || organicResults.isEmpty) {
          return const Right([]);
        }

        // Transform to simpler structure
        final results = organicResults.map((result) {
          return {
            'title': result['title'],
            'link': result['link'],
            'snippet': result['snippet'],
            'position': result['position'],
            'displayed_link': result['displayed_link'],
          };
        }).toList();

        return Right(List<Map<String, dynamic>>.from(results));
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return Left(
          AuthenticationFailure(message: 'Invalid WebSearch API key'),
        );
      } else if (response.statusCode == 429) {
        return Left(
          RateLimitFailure(message: 'WebSearch API rate limit exceeded'),
        );
      } else {
        return Left(
          NetworkFailure(
            message: 'WebSearch API error: ${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      debugPrint('WebSearch error: $e');
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Alternative search using mock data for testing or when API is not configured
  Future<Either<Failure, List<Map<String, dynamic>>>> mockSearch(
    String query,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Create mock results based on query
      final results = [
        {
          'title': 'Top ${query.split(' ').last} Information',
          'link': 'https://example.com/search?q=$query',
          'snippet':
              'This is a sample result about $query with relevant information that would be useful for travel planning.',
          'position': 1,
          'displayed_link': 'example.com',
        },
        {
          'title': 'Best places to visit in ${query.split(' ').last}',
          'link': 'https://travel.example.com/destinations/$query',
          'snippet':
              'Discover the most popular attractions and hidden gems in ${query.split(' ').last}. Plan your perfect trip with our comprehensive guide.',
          'position': 2,
          'displayed_link': 'travel.example.com',
        },
      ];

      return Right(results);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Search with fallback to mock data
  Future<Either<Failure, List<Map<String, dynamic>>>> searchWithFallback(
    String query,
  ) async {
    if (isConfigured) {
      final result = await search(query);
      if (result.isRight()) {
        return result;
      }
      // If the real search fails for any reason, try mock search
      return mockSearch(query);
    } else {
      // If not configured, use mock data
      return mockSearch(query);
    }
  }

  // Generate search queries based on itinerary details
  List<String> generateSearchQueries(Map<String, dynamic> itineraryData) {
    final queries = <String>[];

    // Extract destination from title
    final title = itineraryData['title'] as String?;
    if (title != null) {
      final destination = title.replaceAll('Trip to ', '');
      queries.add('Top attractions in $destination');
      queries.add('Best restaurants in $destination');
    }

    // Extract specific locations from days
    final days = itineraryData['days'] as List<dynamic>?;
    if (days != null && days.isNotEmpty) {
      for (final day in days) {
        final items = day['items'] as List<dynamic>?;
        if (items != null) {
          for (final item in items) {
            final location = item['location'] as String?;
            final activity = item['activity'] as String?;

            if (location != null && location.isNotEmpty) {
              queries.add('Information about $location');
            }

            if (activity != null &&
                (activity.contains('restaurant') ||
                    activity.contains('café') ||
                    activity.contains('cafe'))) {
              queries.add('Reviews for $activity $location');
            }
          }
        }
      }
    }

    // Limit to 5 unique queries
    return queries.toSet().take(5).toList();
  }
}
