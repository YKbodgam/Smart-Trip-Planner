import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

import '../../core/config/environment_config.dart';
import '../../core/error/failures.dart';

class WebSearchService {
  final Dio _dio;

  WebSearchService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Either<Failure, List<SearchResult>>> searchRestaurants({
    required String location,
    String? cuisine,
    String? priceRange,
  }) async {
    String query = 'best restaurants in $location';
    if (cuisine != null) query += ' $cuisine cuisine';
    if (priceRange != null) query += ' $priceRange';

    return performSearch(query, 'restaurant');
  }

  Future<Either<Failure, List<SearchResult>>> searchHotels({
    required String location,
    String? budget,
    String? type,
  }) async {
    String query = 'best hotels in $location';
    if (budget != null) query += ' $budget budget';
    if (type != null) query += ' $type';

    return performSearch(query, 'hotel');
  }

  Future<Either<Failure, List<SearchResult>>> searchAttractions({
    required String location,
    String? category,
  }) async {
    String query = 'top attractions things to do in $location';
    if (category != null) query += ' $category';

    return performSearch(query, 'attraction');
  }

  Future<Either<Failure, List<SearchResult>>> searchTransportation({
    required String from,
    required String to,
    String? mode,
  }) async {
    String query = 'transportation from $from to $to';
    if (mode != null) query += ' $mode';

    return performSearch(query, 'transportation');
  }

  Future<Either<Failure, List<SearchResult>>> searchWeatherInfo({
    required String location,
    String? dateRange,
  }) async {
    String query = 'weather in $location';
    if (dateRange != null) query += ' $dateRange';

    return performSearch(query, 'weather');
  }

  Future<Either<Failure, List<SearchResult>>> searchLocalEvents({
    required String location,
    String? dateRange,
    String? eventType,
  }) async {
    String query = 'events in $location';
    if (dateRange != null) query += ' $dateRange';
    if (eventType != null) query += ' $eventType';

    return performSearch(query, 'event');
  }

  Future<Either<Failure, List<SearchResult>>> performSearch(
    String query,
    String category,
  ) async {
    try {
      if (!EnvironmentConfig.isGoogleSearchConfigured) {
        return Left(
          ConfigurationFailure(message: 'Google Search API not configured'),
        );
      }

      final response = await _dio.get(
        'https://www.googleapis.com/customsearch/v1',
        queryParameters: {
          'key': EnvironmentConfig.googleSearchApiKey,
          'cx': EnvironmentConfig.googleSearchEngineId,
          'q': query,
          'num': 8, // Get more results for better variety
          'safe': 'active',
        },
      );

      final items = response.data['items'] as List<dynamic>? ?? [];
      final results = items
          .map(
            (item) => SearchResult(
              title: item['title'] ?? '',
              url: item['link'] ?? '',
              snippet: item['snippet'] ?? '',
              category: category,
              displayLink: item['displayLink'] ?? '',
              formattedUrl: item['formattedUrl'] ?? '',
              imageUrl: item['pagemap']?['cse_image']?[0]?['src'],
            ),
          )
          .toList();

      return Right(results);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return Left(
          AuthenticationFailure(
            message: 'Google Search API quota exceeded or invalid key',
          ),
        );
      } else if (e.response?.statusCode == 400) {
        return Left(ValidationFailure(message: 'Invalid search parameters'));
      }
      return Left(NetworkFailure(message: e.message ?? 'Search API error'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Enhanced search with multiple queries for comprehensive results
  Future<Either<Failure, Map<String, List<SearchResult>>>>
  searchComprehensiveInfo({
    required String location,
    String? dateRange,
    List<String>? interests,
  }) async {
    final results = <String, List<SearchResult>>{};

    try {
      // Search for restaurants
      final restaurantsResult = await searchRestaurants(location: location);
      restaurantsResult.fold(
        (failure) => results['restaurants'] = [],
        (searchResults) => results['restaurants'] = searchResults,
      );

      // Search for attractions
      final attractionsResult = await searchAttractions(location: location);
      attractionsResult.fold(
        (failure) => results['attractions'] = [],
        (searchResults) => results['attractions'] = searchResults,
      );

      // Search for hotels
      final hotelsResult = await searchHotels(location: location);
      hotelsResult.fold(
        (failure) => results['hotels'] = [],
        (searchResults) => results['hotels'] = searchResults,
      );

      // Search for weather info
      final weatherResult = await searchWeatherInfo(
        location: location,
        dateRange: dateRange,
      );
      weatherResult.fold(
        (failure) => results['weather'] = [],
        (searchResults) => results['weather'] = searchResults,
      );

      // Search for local events if date range is provided
      if (dateRange != null) {
        final eventsResult = await searchLocalEvents(
          location: location,
          dateRange: dateRange,
        );
        eventsResult.fold(
          (failure) => results['events'] = [],
          (searchResults) => results['events'] = searchResults,
        );
      }

      // Search for specific interests
      if (interests != null && interests.isNotEmpty) {
        for (final interest in interests) {
          final interestResult = await performSearch(
            '$interest in $location',
            'interest',
          );
          interestResult.fold(
            (failure) => results[interest] = [],
            (searchResults) => results[interest] = searchResults,
          );
        }
      }

      return Right(results);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}

class SearchResult {
  final String title;
  final String url;
  final String snippet;
  final String category;
  final String displayLink;
  final String formattedUrl;
  final String? imageUrl;

  const SearchResult({
    required this.title,
    required this.url,
    required this.snippet,
    required this.category,
    required this.displayLink,
    required this.formattedUrl,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'url': url,
    'snippet': snippet,
    'category': category,
    'displayLink': displayLink,
    'formattedUrl': formattedUrl,
    'imageUrl': imageUrl,
  };

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
    title: json['title'] ?? '',
    url: json['url'] ?? '',
    snippet: json['snippet'] ?? '',
    category: json['category'] ?? '',
    displayLink: json['displayLink'] ?? '',
    formattedUrl: json['formattedUrl'] ?? '',
    imageUrl: json['imageUrl'],
  );
}
