import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
@collection
class UserModel extends Equatable {
  Id id = Isar.autoIncrement; // ✅ mutable, Isar requires non-final

  @JsonKey(name: 'uid')
  @Index(unique: true)
  final String uid;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'displayName')
  final String? displayName;

  @JsonKey(name: 'photoUrl')
  final String? photoUrl;

  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  @JsonKey(name: 'requestTokensUsed')
  final int requestTokensUsed;

  @JsonKey(name: 'responseTokensUsed')
  final int responseTokensUsed;

  @JsonKey(name: 'totalCost')
  final double totalCost;

  @JsonKey(name: 'preferences')
  final UserPreferencesModel? preferences;

  UserModel({
    this.id = Isar.autoIncrement,
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
    return UserModel(
      id: entity.id ?? Isar.autoIncrement,
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
      id: id == Isar.autoIncrement ? null : id,
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
    Id? id,
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

  @ignore // 👈 prevents Isar from trying to store this
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
@embedded
class UserPreferencesModel extends Equatable {
  @JsonKey(name: 'currency')
  final String currency;

  @JsonKey(name: 'language')
  final String language;

  @JsonKey(name: 'budgetRange')
  final String budgetRange;

  @JsonKey(name: 'travelStyle')
  final String travelStyle;

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

  @ignore // 👈 prevents Isar from trying to store this
  @override
  List<Object?> get props => [
    currency,
    language,
    budgetRange,
    travelStyle,
    interests,
  ];
}
