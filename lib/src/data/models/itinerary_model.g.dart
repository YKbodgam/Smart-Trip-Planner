// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItineraryModelAdapter extends TypeAdapter<ItineraryModel> {
  @override
  final int typeId = 0;

  @override
  ItineraryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItineraryModel(
      id: fields[0] as String,
      title: fields[1] as String,
      startDate: fields[2] as String,
      endDate: fields[3] as String,
      days: (fields[4] as List).cast<ItineraryDayModel>(),
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      isOfflineAvailable: fields[7] as bool,
      totalCost: fields[8] as double?,
      currency: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ItineraryModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.days)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.isOfflineAvailable)
      ..writeByte(8)
      ..write(obj.totalCost)
      ..writeByte(9)
      ..write(obj.currency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItineraryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItineraryDayModelAdapter extends TypeAdapter<ItineraryDayModel> {
  @override
  final int typeId = 1;

  @override
  ItineraryDayModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItineraryDayModel(
      date: fields[0] as String,
      summary: fields[1] as String,
      items: (fields[2] as List).cast<ItineraryItemModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ItineraryDayModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.summary)
      ..writeByte(2)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItineraryDayModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItineraryItemModelAdapter extends TypeAdapter<ItineraryItemModel> {
  @override
  final int typeId = 2;

  @override
  ItineraryItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItineraryItemModel(
      time: fields[0] as String,
      activity: fields[1] as String,
      location: fields[2] as String?,
      description: fields[3] as String?,
      estimatedCost: fields[4] as double?,
      category: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ItineraryItemModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.activity)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.estimatedCost)
      ..writeByte(5)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItineraryItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItineraryModel _$ItineraryModelFromJson(Map<String, dynamic> json) =>
    ItineraryModel(
      id: json['id'] as String,
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
