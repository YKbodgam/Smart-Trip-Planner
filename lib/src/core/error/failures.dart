import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;
  final String? details; // Added details field for more context
  final DateTime timestamp; // Added timestamp for error tracking

  Failure({required this.message, this.code, this.details, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [message, code, details, timestamp];

  String get userFriendlyMessage {
    switch (runtimeType) {
      case NetworkFailure:
        return 'Please check your internet connection and try again.';
      case AuthenticationFailure:
        return 'Please sign in again to continue.';
      case RateLimitFailure:
        return 'Too many requests. Please wait a moment and try again.';
      case AIServiceFailure:
        return 'AI service is temporarily unavailable. Please try again later.';
      case ValidationFailure:
        return 'Please check your input and try again.';
      case DatabaseFailure:
        return 'Data storage error. Please restart the app.';
      case ConfigurationFailure:
        return 'App configuration error. Please contact support.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  ErrorSeverity get severity {
    switch (runtimeType) {
      case NetworkFailure:
      case RateLimitFailure:
        return ErrorSeverity.warning;
      case AuthenticationFailure:
      case AuthorizationFailure:
      case ValidationFailure:
        return ErrorSeverity.error;
      case DatabaseFailure:
      case ConfigurationFailure:
      case PlatformFailure:
        return ErrorSeverity.critical;
      default:
        return ErrorSeverity.info;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'type': runtimeType.toString(),
      'message': message,
      'userFriendlyMessage': userFriendlyMessage,
      'code': code,
      'details': details,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum ErrorSeverity { info, warning, error, critical }

// General failures
class ServerFailure extends Failure {
  ServerFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

class NetworkFailure extends Failure {
  NetworkFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

class CacheFailure extends Failure {
  CacheFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

class ValidationFailure extends Failure {
  ValidationFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

// Authentication failures
class AuthenticationFailure extends Failure {
  AuthenticationFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

class AuthorizationFailure extends Failure {
  AuthorizationFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

// AI/API specific failures
class AIServiceFailure extends Failure {
  AIServiceFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

class TokenLimitFailure extends Failure {
  TokenLimitFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

class RateLimitFailure extends Failure {
  RateLimitFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

// Data parsing failures
class JsonParsingFailure extends Failure {
  JsonParsingFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

class ParsingFailure extends Failure {
  ParsingFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

class DatabaseFailure extends Failure {
  DatabaseFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

class ConfigurationFailure extends Failure {
  ConfigurationFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

class PlatformFailure extends Failure {
  PlatformFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

class PermissionFailure extends Failure {
  PermissionFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

class TimeoutFailure extends Failure {
  TimeoutFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}

// Unknown failure
class UnknownFailure extends Failure {
  UnknownFailure({
    required super.message,
    super.code,
    super.details,
    super.timestamp,
  });
}
