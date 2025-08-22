import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/itinerary.dart';

part 'itinerary_model.g.dart';

@JsonSerializable()
@collection
class ItineraryModel extends Equatable {
  Id id = Isar.autoIncrement; // ✅ mutable, Isar requires non-final

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'startDate')
  final String startDate;

  @JsonKey(name: 'endDate')
  final String endDate;

  @JsonKey(name: 'days')
  final List<ItineraryDayModel> days;

  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  @JsonKey(name: 'isOfflineAvailable')
  final bool isOfflineAvailable;

  @JsonKey(name: 'totalCost')
  final double? totalCost;

  @JsonKey(name: 'currency')
  final String? currency;

  ItineraryModel({
    this.id = Isar.autoIncrement,
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
      id: entity.id ?? Isar.autoIncrement,
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
      id: id == Isar.autoIncrement ? null : id,
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
    Id? id,
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

  @ignore // 👈 prevents Isar from trying to store this
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
@embedded
class ItineraryDayModel extends Equatable {
  @JsonKey(name: 'date')
  final String date;

  @JsonKey(name: 'summary')
  final String summary;

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

  @ignore // 👈 prevents Isar from trying to store this
  @override
  List<Object?> get props => [date, summary, items];
}

@JsonSerializable()
@embedded
class ItineraryItemModel extends Equatable {
  @JsonKey(name: 'time')
  final String time;

  @JsonKey(name: 'activity')
  final String activity;

  @JsonKey(name: 'location')
  final String? location;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'estimatedCost')
  final double? estimatedCost;

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

  @ignore // 👈 prevents Isar from trying to store this
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
