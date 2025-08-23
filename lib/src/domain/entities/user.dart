import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String? id;
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int requestTokensUsed;
  final int responseTokensUsed;
  final double totalCost;
  final UserPreferences? preferences;

  const User({
    this.id,
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

  User copyWith({
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
    UserPreferences? preferences,
  }) {
    return User(
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

class UserPreferences extends Equatable {
  final String currency;
  final String language;
  final String budgetRange;
  final String travelStyle;
  final List<String> interests;

  const UserPreferences({
    required this.currency,
    required this.language,
    required this.budgetRange,
    required this.travelStyle,
    required this.interests,
  });

  UserPreferences copyWith({
    String? currency,
    String? language,
    String? budgetRange,
    String? travelStyle,
    List<String>? interests,
  }) {
    return UserPreferences(
      currency: currency ?? this.currency,
      language: language ?? this.language,
      budgetRange: budgetRange ?? this.budgetRange,
      travelStyle: travelStyle ?? this.travelStyle,
      interests: interests ?? this.interests,
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
