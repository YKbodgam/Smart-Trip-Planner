import 'dart:math';
import 'package:intl/intl.dart';
import 'package:pathoria/src/data/models/itinerary_model.dart';

/// Helper class for safely creating ItineraryModel from API responses
class ItineraryModelHelper {
  /// Creates an ItineraryModel from a potentially incomplete JSON response
  static ItineraryModel safeFromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    // Generate a unique ID if missing
    final id = json['id'] ?? 'itinerary_${now.millisecondsSinceEpoch}';

    // Extract dates or provide defaults
    final String startDate = json['startDate'] ?? _formatDate(now);
    final String endDate =
        json['endDate'] ?? _formatDate(now.add(Duration(days: 3)));

    // Process days data with safety checks
    List<ItineraryDayModel> days = [];
    if (json['days'] != null && json['days'] is List) {
      days = _processDaysData(json['days'] as List, startDate);
    } else {
      // Create a default day if none provided
      days = [_createDefaultDay(startDate)];
    }

    return ItineraryModel(
      id: id,
      title: json['title'] ?? 'New Trip Plan',
      startDate: startDate,
      endDate: endDate,
      days: days,
      createdAt: _parseDateTime(json['createdAt']) ?? now,
      updatedAt: _parseDateTime(json['updatedAt']) ?? now,
      isOfflineAvailable: json['isOfflineAvailable'] as bool? ?? false,
      totalCost: json['totalCost'] is num
          ? (json['totalCost'] as num).toDouble()
          : null,
      currency: json['currency'] as String?,
    );
  }

  /// Process a list of day data from the API
  static List<ItineraryDayModel> _processDaysData(
    List daysList,
    String fallbackStartDate,
  ) {
    final List<ItineraryDayModel> processedDays = [];

    for (var i = 0; i < daysList.length; i++) {
      final dayData = daysList[i] as Map<String, dynamic>? ?? {};

      // Create a date based on fallback date + index
      final String date =
          dayData['date'] ?? _calculateDate(fallbackStartDate, i);

      // Process items within the day
      List<ItineraryItemModel> items = [];
      if (dayData['items'] != null && dayData['items'] is List) {
        items = _processItemsData(dayData['items'] as List);
      }

      processedDays.add(
        ItineraryDayModel(
          date: date,
          summary: dayData['summary'] ?? 'Day ${i + 1} Activities',
          items: items.isEmpty ? [_createDefaultItem()] : items,
        ),
      );
    }

    return processedDays;
  }

  /// Process a list of item data from the API
  static List<ItineraryItemModel> _processItemsData(List itemsList) {
    final List<ItineraryItemModel> processedItems = [];

    for (var itemData in itemsList) {
      if (itemData is Map<String, dynamic>) {
        // Handle case where timeOfDay is used instead of time
        final String time =
            itemData['time'] ?? itemData['timeOfDay'] ?? _generateTimeOfDay();

        processedItems.add(
          ItineraryItemModel(
            time: time,
            activity: itemData['activity'] ?? 'Explore local area',
            location: itemData['location'] as String?,
            description: itemData['description'] as String?,
            estimatedCost: itemData['estimatedCost'] is num
                ? (itemData['estimatedCost'] as num).toDouble()
                : null,
            category: itemData['category'] as String?,
          ),
        );
      }
    }

    return processedItems;
  }

  /// Create a default day entry
  static ItineraryDayModel _createDefaultDay(String date) {
    return ItineraryDayModel(
      date: date,
      summary: 'Day 1 Activities',
      items: [_createDefaultItem()],
    );
  }

  /// Create a default item entry
  static ItineraryItemModel _createDefaultItem() {
    return ItineraryItemModel(
      time: 'Morning',
      activity: 'Start exploring the destination',
      location: null,
      description: null,
      estimatedCost: null,
      category: null,
    );
  }

  /// Format a date to string
  static String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Calculate a date based on a start date and offset
  static String _calculateDate(String startDate, int dayOffset) {
    try {
      final start = DateFormat('yyyy-MM-dd').parse(startDate);
      return _formatDate(start.add(Duration(days: dayOffset)));
    } catch (e) {
      return _formatDate(DateTime.now().add(Duration(days: dayOffset)));
    }
  }

  /// Generate a random time of day
  static String _generateTimeOfDay() {
    final times = ['Morning', 'Afternoon', 'Evening'];
    return times[Random().nextInt(times.length)];
  }

  /// Safely parse a datetime string
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return null;
      }
    }

    return null;
  }
}
