import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'failures.dart';
import 'error_logger.dart';

class GlobalErrorHandler {
  static final ErrorLogger _logger = ErrorLogger();

  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Handle errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };

    // Handle unhandled async errors
    runZonedGuarded(() {}, (error, stack) {
      _handleAsyncError(error, stack);
    });
  }

  static void _handleFlutterError(FlutterErrorDetails details) {
    final failure = UnknownFailure(
      message: details.exception.toString(),
      details: details.stack.toString(),
    );

    _logger.logError(failure, details.stack);

    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  static void _handlePlatformError(Object error, StackTrace stack) {
    final failure = UnknownFailure(
      message: error.toString(),
      details: stack.toString(),
    );

    _logger.logError(failure, stack);

    if (kDebugMode) {
      print('Platform Error: $error\n$stack');
    }
  }

  static void _handleAsyncError(Object error, StackTrace stack) {
    final failure = UnknownFailure(
      message: error.toString(),
      details: stack.toString(),
    );

    _logger.logError(failure, stack);

    if (kDebugMode) {
      print('Async Error: $error\n$stack');
    }
  }

  static Failure handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(
          message: 'Request timeout',
          details: error.message,
          code: error.response?.statusCode,
        );

      case DioExceptionType.connectionError:
        return NetworkFailure(
          message: 'Network connection error',
          details: error.message,
          code: error.response?.statusCode,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return ValidationFailure(
              message: 'Invalid request',
              details: error.response?.data?.toString(),
              code: statusCode,
            );
          case 401:
            return AuthenticationFailure(
              message: 'Authentication failed',
              details: error.response?.data?.toString(),
              code: statusCode,
            );
          case 403:
            return AuthorizationFailure(
              message: 'Access denied',
              details: error.response?.data?.toString(),
              code: statusCode,
            );
          case 429:
            return RateLimitFailure(
              message: 'Rate limit exceeded',
              details: error.response?.data?.toString(),
              code: statusCode,
            );
          case 500:
          case 502:
          case 503:
          case 504:
            return ServerFailure(
              message: 'Server error',
              details: error.response?.data?.toString(),
              code: statusCode,
            );
          default:
            return ServerFailure(
              message: 'HTTP error',
              details: error.response?.data?.toString(),
              code: statusCode,
            );
        }

      case DioExceptionType.cancel:
        return UnknownFailure(
          message: 'Request cancelled',
          details: error.message,
        );

      case DioExceptionType.unknown:
      default:
        return UnknownFailure(
          message: 'Unknown network error',
          details: error.message,
        );
    }
  }

  static Failure handlePlatformException(PlatformException error) {
    switch (error.code) {
      case 'PERMISSION_DENIED':
        return PermissionFailure(
          message: 'Permission denied',
          details: error.message,
          code: int.tryParse(error.code),
        );
      case 'UNAVAILABLE':
        return PlatformFailure(
          message: 'Service unavailable',
          details: error.message,
          code: int.tryParse(error.code),
        );
      default:
        return PlatformFailure(
          message: error.message ?? 'Platform error',
          details: error.details?.toString(),
          code: int.tryParse(error.code),
        );
    }
  }

  static Failure handleSocketException(SocketException error) {
    return NetworkFailure(
      message: 'Network connection failed',
      details: error.message,
    );
  }

  static Failure handleFormatException(FormatException error) {
    return JsonParsingFailure(
      message: 'Data parsing error',
      details: error.message,
    );
  }

  static Failure handleTimeoutException(TimeoutException error) {
    return TimeoutFailure(message: 'Operation timeout', details: error.message);
  }

  static Failure handleGenericError(Object error, [StackTrace? stackTrace]) {
    // Log the error
    final failure = UnknownFailure(
      message: error.toString(),
      details: stackTrace?.toString(),
    );

    _logger.logError(failure, stackTrace);

    // Handle specific error types
    if (error is DioException) {
      return handleDioError(error);
    } else if (error is PlatformException) {
      return handlePlatformException(error);
    } else if (error is SocketException) {
      return handleSocketException(error);
    } else if (error is FormatException) {
      return handleFormatException(error);
    } else if (error is TimeoutException) {
      return handleTimeoutException(error);
    }

    return failure;
  }

  static void reportError(Failure failure, [StackTrace? stackTrace]) {
    _logger.logError(failure, stackTrace);
  }
}
