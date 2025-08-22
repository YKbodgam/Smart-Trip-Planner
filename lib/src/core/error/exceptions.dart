class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  const ServerException({
    required this.message,
    this.statusCode,
  });
  
  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException({
    required this.message,
  });
  
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException({
    required this.message,
  });
  
  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;
  
  const ValidationException({
    required this.message,
    this.errors,
  });
  
  @override
  String toString() => 'ValidationException: $message';
}

class AuthenticationException implements Exception {
  final String message;
  final String? code;
  
  const AuthenticationException({
    required this.message,
    this.code,
  });
  
  @override
  String toString() => 'AuthenticationException: $message (Code: $code)';
}

class AIServiceException implements Exception {
  final String message;
  final int? statusCode;
  final String? model;
  
  const AIServiceException({
    required this.message,
    this.statusCode,
    this.model,
  });
  
  @override
  String toString() => 'AIServiceException: $message (Model: $model, Status: $statusCode)';
}

class TokenLimitException implements Exception {
  final String message;
  final int? tokensUsed;
  final int? tokenLimit;
  
  const TokenLimitException({
    required this.message,
    this.tokensUsed,
    this.tokenLimit,
  });
  
  @override
  String toString() => 'TokenLimitException: $message (Used: $tokensUsed, Limit: $tokenLimit)';
}

class RateLimitException implements Exception {
  final String message;
  final Duration? retryAfter;
  
  const RateLimitException({
    required this.message,
    this.retryAfter,
  });
  
  @override
  String toString() => 'RateLimitException: $message (Retry after: $retryAfter)';
}

class JsonParsingException implements Exception {
  final String message;
  final String? json;
  
  const JsonParsingException({
    required this.message,
    this.json,
  });
  
  @override
  String toString() => 'JsonParsingException: $message';
}

class DatabaseException implements Exception {
  final String message;
  final String? operation;
  
  const DatabaseException({
    required this.message,
    this.operation,
  });
  
  @override
  String toString() => 'DatabaseException: $message (Operation: $operation)';
}
