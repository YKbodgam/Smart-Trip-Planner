import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/itinerary.dart';

class MapsService {
  static const String _googleMapsBaseUrl = 'https://www.google.com/maps';
  static const String _appleMapsBaseUrl = 'https://maps.apple.com';

  Future<Either<Failure, void>> openLocationInMaps({
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      Uri? uri;

      if (latitude != null && longitude != null) {
        // Use coordinates if available
        uri = _buildMapsUriWithCoordinates(latitude, longitude);
      } else {
        // Use location string for search
        uri = _buildMapsUriWithQuery(location);
      }

      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return const Right(null);
      } else {
        return Left(
          PlatformFailure(message: 'Could not open maps application'),
        );
      }
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> openItineraryItemInMaps(
    ItineraryItem item,
  ) async {
    final coordinates = _parseCoordinates(item.location);

    return await openLocationInMaps(
      location: item.location ?? item.activity,
      latitude: coordinates?['lat'],
      longitude: coordinates?['lng'],
    );
  }

  Future<Either<Failure, void>> openDirections({
    required String from,
    required String to,
    double? fromLat,
    double? fromLng,
    double? toLat,
    double? toLng,
    String? travelMode,
  }) async {
    try {
      Uri? uri;

      if (Platform.isIOS) {
        uri = _buildAppleDirectionsUri(
          from: from,
          to: to,
          fromLat: fromLat,
          fromLng: fromLng,
          toLat: toLat,
          toLng: toLng,
          travelMode: travelMode,
        );
      } else {
        uri = _buildGoogleDirectionsUri(
          from: from,
          to: to,
          fromLat: fromLat,
          fromLng: fromLng,
          toLat: toLat,
          toLng: toLng,
          travelMode: travelMode,
        );
      }

      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return Right(null);
      } else {
        return Left(PlatformFailure(message: 'Could not open directions'));
      }
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> openItineraryInMaps(Itinerary itinerary) async {
    try {
      // Get all locations from the itinerary
      final locations = <Map<String, dynamic>>[];

      for (final day in itinerary.days) {
        for (final item in day.items) {
          if (item.location != null && item.location!.isNotEmpty) {
            final coordinates = _parseCoordinates(item.location);
            locations.add({
              'name': item.activity,
              'location': item.location,
              'lat': coordinates?['lat'],
              'lng': coordinates?['lng'],
            });
          }
        }
      }

      if (locations.isEmpty) {
        return Left(
          ValidationFailure(message: 'No locations found in itinerary'),
        );
      }

      // Open the first location (could be enhanced to show all locations)
      final firstLocation = locations.first;
      return await openLocationInMaps(
        location: firstLocation['location'] ?? firstLocation['name'],
        latitude: firstLocation['lat'],
        longitude: firstLocation['lng'],
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Uri? _buildMapsUriWithCoordinates(double latitude, double longitude) {
    if (Platform.isIOS) {
      return Uri.parse('$_appleMapsBaseUrl/?ll=$latitude,$longitude');
    } else {
      return Uri.parse(
        '$_googleMapsBaseUrl/search/?api=1&query=$latitude,$longitude',
      );
    }
  }

  Uri? _buildMapsUriWithQuery(String query) {
    final encodedQuery = Uri.encodeComponent(query);

    if (Platform.isIOS) {
      return Uri.parse('$_appleMapsBaseUrl/?q=$encodedQuery');
    } else {
      return Uri.parse('$_googleMapsBaseUrl/search/?api=1&query=$encodedQuery');
    }
  }

  Uri? _buildGoogleDirectionsUri({
    required String from,
    required String to,
    double? fromLat,
    double? fromLng,
    double? toLat,
    double? toLng,
    String? travelMode,
  }) {
    final origin = (fromLat != null && fromLng != null)
        ? '$fromLat,$fromLng'
        : Uri.encodeComponent(from);
    final destination = (toLat != null && toLng != null)
        ? '$toLat,$toLng'
        : Uri.encodeComponent(to);

    String url =
        '$_googleMapsBaseUrl/dir/?api=1&origin=$origin&destination=$destination';

    if (travelMode != null) {
      url += '&travelmode=${_convertTravelMode(travelMode)}';
    }

    return Uri.parse(url);
  }

  Uri? _buildAppleDirectionsUri({
    required String from,
    required String to,
    double? fromLat,
    double? fromLng,
    double? toLat,
    double? toLng,
    String? travelMode,
  }) {
    String url = '$_appleMapsBaseUrl/?';

    if (fromLat != null && fromLng != null) {
      url += 'sll=$fromLat,$fromLng&';
    } else {
      url += 'saddr=${Uri.encodeComponent(from)}&';
    }

    if (toLat != null && toLng != null) {
      url += 'dll=$toLat,$toLng';
    } else {
      url += 'daddr=${Uri.encodeComponent(to)}';
    }

    if (travelMode != null) {
      url += '&dirflg=${_convertAppleTravelMode(travelMode)}';
    }

    return Uri.parse(url);
  }

  Map<String, double>? _parseCoordinates(String? location) {
    if (location == null || location.isEmpty) return null;

    // Try to parse coordinates in format "lat,lng" or "latitude,longitude"
    final coordPattern = RegExp(r'^(-?\d+\.?\d*),\s*(-?\d+\.?\d*)$');
    final match = coordPattern.firstMatch(location.trim());

    if (match != null) {
      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);

      if (lat != null && lng != null) {
        return {'lat': lat, 'lng': lng};
      }
    }

    return null;
  }

  String _convertTravelMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'driving':
      case 'car':
        return 'driving';
      case 'walking':
      case 'walk':
        return 'walking';
      case 'bicycling':
      case 'bike':
        return 'bicycling';
      case 'transit':
      case 'public':
        return 'transit';
      default:
        return 'driving';
    }
  }

  String _convertAppleTravelMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'driving':
      case 'car':
        return 'd';
      case 'walking':
      case 'walk':
        return 'w';
      case 'transit':
      case 'public':
        return 'r';
      default:
        return 'd';
    }
  }

  // Utility method to validate coordinates
  bool isValidCoordinate(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  // Extract location name from coordinates or address
  String getLocationDisplayName(String? location) {
    if (location == null || location.isEmpty) return 'Unknown Location';

    final coordinates = _parseCoordinates(location);
    if (coordinates != null) {
      return 'Location (${coordinates['lat']!.toStringAsFixed(4)}, ${coordinates['lng']!.toStringAsFixed(4)})';
    }

    return location;
  }
}
