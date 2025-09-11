import 'package:equatable/equatable.dart';

class Itinerary extends Equatable {
  final String? id;
  final String title;
  final String startDate;
  final String endDate;
  final List<ItineraryDay> days;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOfflineAvailable;
  final double? totalCost;
  final String? currency;

  const Itinerary({
    this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.createdAt,
    required this.updatedAt,
    this.isOfflineAvailable = false,
    this.totalCost,
    this.currency,
  });

  Itinerary copyWith({
    String? id,
    String? title,
    String? startDate,
    String? endDate,
    List<ItineraryDay>? days,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOfflineAvailable,
    double? totalCost,
    String? currency,
  }) {
    return Itinerary(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOfflineAvailable: isOfflineAvailable ?? this.isOfflineAvailable,
      totalCost: totalCost ?? this.totalCost,
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    startDate,
    endDate,
    days,
    createdAt,
    updatedAt,
    isOfflineAvailable,
    totalCost,
    currency,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'days': days.map((day) => day.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isOfflineAvailable': isOfflineAvailable,
      'totalCost': totalCost,
      'currency': currency,
    };
  }
}

class ItineraryDay extends Equatable {
  final String date;
  final String summary;
  final List<ItineraryItem> items;

  const ItineraryDay({
    required this.date,
    required this.summary,
    required this.items,
  });

  ItineraryDay copyWith({
    String? date,
    String? summary,
    List<ItineraryItem>? items,
  }) {
    return ItineraryDay(
      date: date ?? this.date,
      summary: summary ?? this.summary,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [date, summary, items];

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'summary': summary,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class ItineraryItem extends Equatable {
  final String time;
  final String activity;
  final String? location;
  final String? description;
  final double? estimatedCost;
  final String? category;

  const ItineraryItem({
    required this.time,
    required this.activity,
    this.location,
    this.description,
    this.estimatedCost,
    this.category,
  });

  ItineraryItem copyWith({
    String? time,
    String? activity,
    String? location,
    String? description,
    double? estimatedCost,
    String? category,
  }) {
    return ItineraryItem(
      time: time ?? this.time,
      activity: activity ?? this.activity,
      location: location ?? this.location,
      description: description ?? this.description,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
    time,
    activity,
    location,
    description,
    estimatedCost,
    category,
  ];

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'activity': activity,
      'location': location,
      'description': description,
      'estimatedCost': estimatedCost,
      'category': category,
    };
  }
}
