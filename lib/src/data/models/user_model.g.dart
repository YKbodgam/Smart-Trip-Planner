// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 3;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      uid: fields[1] as String,
      email: fields[2] as String,
      displayName: fields[3] as String?,
      photoUrl: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      requestTokensUsed: fields[7] as int,
      responseTokensUsed: fields[8] as int,
      totalCost: fields[9] as double,
      preferences: fields[10] as UserPreferencesModel?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.displayName)
      ..writeByte(4)
      ..write(obj.photoUrl)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.requestTokensUsed)
      ..writeByte(8)
      ..write(obj.responseTokensUsed)
      ..writeByte(9)
      ..write(obj.totalCost)
      ..writeByte(10)
      ..write(obj.preferences);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserPreferencesModelAdapter extends TypeAdapter<UserPreferencesModel> {
  @override
  final int typeId = 4;

  @override
  UserPreferencesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferencesModel(
      currency: fields[0] as String,
      language: fields[1] as String,
      budgetRange: fields[2] as String,
      travelStyle: fields[3] as String,
      interests: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferencesModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.currency)
      ..writeByte(1)
      ..write(obj.language)
      ..writeByte(2)
      ..write(obj.budgetRange)
      ..writeByte(3)
      ..write(obj.travelStyle)
      ..writeByte(4)
      ..write(obj.interests);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      requestTokensUsed: (json['requestTokensUsed'] as num?)?.toInt() ?? 0,
      responseTokensUsed: (json['responseTokensUsed'] as num?)?.toInt() ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      preferences: json['preferences'] == null
          ? null
          : UserPreferencesModel.fromJson(
              json['preferences'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'requestTokensUsed': instance.requestTokensUsed,
      'responseTokensUsed': instance.responseTokensUsed,
      'totalCost': instance.totalCost,
      'preferences': instance.preferences,
    };

UserPreferencesModel _$UserPreferencesModelFromJson(
        Map<String, dynamic> json) =>
    UserPreferencesModel(
      currency: json['currency'] as String,
      language: json['language'] as String,
      budgetRange: json['budgetRange'] as String,
      travelStyle: json['travelStyle'] as String,
      interests:
          (json['interests'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UserPreferencesModelToJson(
        UserPreferencesModel instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'language': instance.language,
      'budgetRange': instance.budgetRange,
      'travelStyle': instance.travelStyle,
      'interests': instance.interests,
    };
