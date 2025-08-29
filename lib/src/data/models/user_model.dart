import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 3) // Replaced Isar Collection with Hive HiveType
class UserModel extends Equatable {
  @HiveField(0) // Replaced Isar Id with Hive HiveField
  final String id;

  @HiveField(1)
  @JsonKey(name: 'uid')
  final String uid;

  @HiveField(2)
  @JsonKey(name: 'email')
  final String email;

  @HiveField(3)
  @JsonKey(name: 'displayName')
  final String? displayName;

  @HiveField(4)
  @JsonKey(name: 'photoUrl')
  final String? photoUrl;

  @HiveField(5)
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @HiveField(6)
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  @HiveField(7)
  @JsonKey(name: 'requestTokensUsed')
  final int requestTokensUsed;

  @HiveField(8)
  @JsonKey(name: 'responseTokensUsed')
  final int responseTokensUsed;

  @HiveField(9)
  @JsonKey(name: 'totalCost')
  final double totalCost;

  @HiveField(10)
  @JsonKey(name: 'preferences')
  final UserPreferencesModel? preferences;

  const UserModel({
    required this.id, // Changed from auto-increment to required String id
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.requestTokensUsed = 0,
    this.responseTokensUsed = 0,
    this.totalCost = 0.0,
    this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User entity) {
    debugPrint('🔄 Converting User entity to UserModel: ${entity.uid}');
    final id = entity.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    debugPrint('🆔 Generated ID: $id');
    
    return UserModel(
      id: id,
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      requestTokensUsed: entity.requestTokensUsed,
      responseTokensUsed: entity.responseTokensUsed,
      totalCost: entity.totalCost,
      preferences: entity.preferences != null
          ? UserPreferencesModel.fromEntity(entity.preferences!)
          : null,
    );
  }

  User toEntity() {
    return User(
      id: id,
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      requestTokensUsed: requestTokensUsed,
      responseTokensUsed: responseTokensUsed,
      totalCost: totalCost,
      preferences: preferences?.toEntity(),
    );
  }

  UserModel copyWith({
    String? id,
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? requestTokensUsed,
    int? responseTokensUsed,
    double? totalCost,
    UserPreferencesModel? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      requestTokensUsed: requestTokensUsed ?? this.requestTokensUsed,
      responseTokensUsed: responseTokensUsed ?? this.responseTokensUsed,
      totalCost: totalCost ?? this.totalCost,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
    id,
    uid,
    email,
    displayName,
    photoUrl,
    createdAt,
    updatedAt,
    requestTokensUsed,
    responseTokensUsed,
    totalCost,
    preferences,
  ];
}

@JsonSerializable()
@HiveType(typeId: 4) // Added Hive type annotation
class UserPreferencesModel extends Equatable {
  @HiveField(0)
  @JsonKey(name: 'currency')
  final String currency;

  @HiveField(1)
  @JsonKey(name: 'language')
  final String language;

  @HiveField(2)
  @JsonKey(name: 'budgetRange')
  final String budgetRange;

  @HiveField(3)
  @JsonKey(name: 'travelStyle')
  final String travelStyle;

  @HiveField(4)
  @JsonKey(name: 'interests')
  final List<String> interests;

  const UserPreferencesModel({
    required this.currency,
    required this.language,
    required this.budgetRange,
    required this.travelStyle,
    required this.interests,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesModelToJson(this);

  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    return UserPreferencesModel(
      currency: entity.currency,
      language: entity.language,
      budgetRange: entity.budgetRange,
      travelStyle: entity.travelStyle,
      interests: entity.interests,
    );
  }

  UserPreferences toEntity() {
    return UserPreferences(
      currency: currency,
      language: language,
      budgetRange: budgetRange,
      travelStyle: travelStyle,
      interests: interests,
    );
  }

  @override
  List<Object?> get props => [
    currency,
    language,
    budgetRange,
    travelStyle,
    interests,
  ];
}
