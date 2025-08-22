// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItineraryModel _$ItineraryModelFromJson(Map<String, dynamic> json) =>
    ItineraryModel(
      id: (json['id'] as num?)?.toInt() ?? Isar.autoIncrement,
      title: json['title'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      days: (json['days'] as List<dynamic>)
          .map((e) => ItineraryDayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isOfflineAvailable: json['isOfflineAvailable'] as bool? ?? false,
      totalCost: (json['totalCost'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$ItineraryModelToJson(ItineraryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'days': instance.days,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isOfflineAvailable': instance.isOfflineAvailable,
      'totalCost': instance.totalCost,
      'currency': instance.currency,
    };

ItineraryDayModel _$ItineraryDayModelFromJson(Map<String, dynamic> json) =>
    ItineraryDayModel(
      date: json['date'] as String,
      summary: json['summary'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ItineraryItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ItineraryDayModelToJson(ItineraryDayModel instance) =>
    <String, dynamic>{
      'date': instance.date,
      'summary': instance.summary,
      'items': instance.items,
    };

ItineraryItemModel _$ItineraryItemModelFromJson(Map<String, dynamic> json) =>
    ItineraryItemModel(
      time: json['time'] as String,
      activity: json['activity'] as String,
      location: json['location'] as String?,
      description: json['description'] as String?,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      category: json['category'] as String?,
    );

Map<String, dynamic> _$ItineraryItemModelToJson(ItineraryItemModel instance) =>
    <String, dynamic>{
      'time': instance.time,
      'activity': instance.activity,
      'location': instance.location,
      'description': instance.description,
      'estimatedCost': instance.estimatedCost,
      'category': instance.category,
    };
