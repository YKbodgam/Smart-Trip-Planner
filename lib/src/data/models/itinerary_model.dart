import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/itinerary.dart';

part 'itinerary_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 0) // Replaced Isar Collection with Hive HiveType
class ItineraryModel extends Equatable {
  @HiveField(0) // Replaced Isar Id with Hive HiveField
  final String id;

  @HiveField(1)
  @JsonKey(name: 'title')
  final String title;

  @HiveField(2)
  @JsonKey(name: 'startDate')
  final String startDate;

  @HiveField(3)
  @JsonKey(name: 'endDate')
  final String endDate;

  @HiveField(4)
  @JsonKey(name: 'days')
  final List<ItineraryDayModel> days;

  @HiveField(5)
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @HiveField(6)
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  @HiveField(7)
  @JsonKey(name: 'isOfflineAvailable')
  final bool isOfflineAvailable;

  @HiveField(8)
  @JsonKey(name: 'totalCost')
  final double? totalCost;

  @HiveField(9)
  @JsonKey(name: 'currency')
  final String? currency;

  const ItineraryModel({
    required this.id, // Changed from auto-increment to required String id
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

  factory ItineraryModel.fromJson(Map<String, dynamic> json) =>
      _$ItineraryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItineraryModelToJson(this);

  factory ItineraryModel.fromEntity(Itinerary entity) {
    return ItineraryModel(
      id:
          entity.id ??
          DateTime.now().millisecondsSinceEpoch
              .toString(), // Generate string ID if null
      title: entity.title,
      startDate: entity.startDate,
      endDate: entity.endDate,
      days: entity.days
          .map((day) => ItineraryDayModel.fromEntity(day))
          .toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isOfflineAvailable: entity.isOfflineAvailable,
      totalCost: entity.totalCost,
      currency: entity.currency,
    );
  }

  Itinerary toEntity() {
    return Itinerary(
      id: id,
      title: title,
      startDate: startDate,
      endDate: endDate,
      days: days.map((day) => day.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isOfflineAvailable: isOfflineAvailable,
      totalCost: totalCost,
      currency: currency,
    );
  }

  ItineraryModel copyWith({
    String? id,
    String? title,
    String? startDate,
    String? endDate,
    List<ItineraryDayModel>? days,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOfflineAvailable,
    double? totalCost,
    String? currency,
  }) {
    return ItineraryModel(
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
}

@JsonSerializable()
@HiveType(typeId: 1) // Added Hive type annotation
class ItineraryDayModel extends Equatable {
  @HiveField(0)
  @JsonKey(name: 'date')
  final String date;

  @HiveField(1)
  @JsonKey(name: 'summary')
  final String summary;

  @HiveField(2)
  @JsonKey(name: 'items')
  final List<ItineraryItemModel> items;

  const ItineraryDayModel({
    required this.date,
    required this.summary,
    required this.items,
  });

  factory ItineraryDayModel.fromJson(Map<String, dynamic> json) =>
      _$ItineraryDayModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItineraryDayModelToJson(this);

  factory ItineraryDayModel.fromEntity(ItineraryDay entity) {
    return ItineraryDayModel(
      date: entity.date,
      summary: entity.summary,
      items: entity.items
          .map((item) => ItineraryItemModel.fromEntity(item))
          .toList(),
    );
  }

  ItineraryDay toEntity() {
    return ItineraryDay(
      date: date,
      summary: summary,
      items: items.map((item) => item.toEntity()).toList(),
    );
  }

  @override
  List<Object?> get props => [date, summary, items];
}

@JsonSerializable()
@HiveType(typeId: 2) // Added Hive type annotation
class ItineraryItemModel extends Equatable {
  @HiveField(0)
  @JsonKey(name: 'time')
  final String time;

  @HiveField(1)
  @JsonKey(name: 'activity')
  final String activity;

  @HiveField(2)
  @JsonKey(name: 'location')
  final String? location;

  @HiveField(3)
  @JsonKey(name: 'description')
  final String? description;

  @HiveField(4)
  @JsonKey(name: 'estimatedCost')
  final double? estimatedCost;

  @HiveField(5)
  @JsonKey(name: 'category')
  final String? category;

  const ItineraryItemModel({
    required this.time,
    required this.activity,
    this.location,
    this.description,
    this.estimatedCost,
    this.category,
  });

  factory ItineraryItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItineraryItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItineraryItemModelToJson(this);

  factory ItineraryItemModel.fromEntity(ItineraryItem entity) {
    return ItineraryItemModel(
      time: entity.time,
      activity: entity.activity,
      location: entity.location,
      description: entity.description,
      estimatedCost: entity.estimatedCost,
      category: entity.category,
    );
  }

  ItineraryItem toEntity() {
    return ItineraryItem(
      time: time,
      activity: activity,
      location: location,
      description: description,
      estimatedCost: estimatedCost,
      category: category,
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
}
