import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../config/app_config.dart';
import 'failures.dart';

class ErrorLogger {
  static const String _logFileName = 'error_logs.txt';
  static const int _maxLogFileSize = 5 * 1024 * 1024; // 5MB
  static const int _maxLogEntries = 1000;

  Future<void> logError(Failure failure, [StackTrace? stackTrace]) async {
    try {
      final logEntry = _createLogEntry(failure, stackTrace);

      // Log to console in debug mode
      if (kDebugMode) {
        print('ERROR: ${failure.runtimeType} - ${failure.message}');
        if (failure.details != null) {
          print('Details: ${failure.details}');
        }
        if (stackTrace != null) {
          print('Stack trace: $stackTrace');
        }
      }

      // Log to file in production
      await _writeToLogFile(logEntry);

      // Send to crash reporting service if enabled
      if (AppConfig.enableCrashReporting) {
        await _sendToCrashReporting(failure, stackTrace);
      }

      // Send to analytics if enabled
      if (AppConfig.enableAnalytics) {
        await _sendToAnalytics(failure);
      }
    } catch (e) {
      // Fallback logging - don't let logging errors crash the app
      if (kDebugMode) {
        print('Failed to log error: $e');
      }
    }
  }

  Map<String, dynamic> _createLogEntry(
    Failure failure, [
    StackTrace? stackTrace,
  ]) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'type': failure.runtimeType.toString(),
      'message': failure.message,
      'userFriendlyMessage': failure.userFriendlyMessage,
      'code': failure.code,
      'details': failure.details,
      'severity': failure.severity.name,
      'stackTrace': stackTrace?.toString(),
    };
  }

  Future<void> _writeToLogFile(Map<String, dynamic> logEntry) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/$_logFileName');

      // Check file size and rotate if necessary
      if (await logFile.exists()) {
        final fileSize = await logFile.length();
        if (fileSize > _maxLogFileSize) {
          await _rotateLogFile(logFile);
        }
      }

      // Append log entry
      final logLine = '${jsonEncode(logEntry)}\n';
      await logFile.writeAsString(logLine, mode: FileMode.append);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to write to log file: $e');
      }
    }
  }

  Future<void> _rotateLogFile(File logFile) async {
    try {
      // Create backup file
      final backupFile = File('${logFile.path}.backup');
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
      await logFile.rename(backupFile.path);

      // Keep only recent entries in the backup
      await _trimLogFile(backupFile);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to rotate log file: $e');
      }
    }
  }

  Future<void> _trimLogFile(File logFile) async {
    try {
      final lines = await logFile.readAsLines();
      if (lines.length > _maxLogEntries) {
        final recentLines = lines.skip(lines.length - _maxLogEntries).toList();
        await logFile.writeAsString(recentLines.join('\n'));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to trim log file: $e');
      }
    }
  }

  Future<void> _sendToCrashReporting(
    Failure failure, [
    StackTrace? stackTrace,
  ]) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        failure,
        stackTrace,
        reason: failure.message,
        fatal: failure.severity == ErrorSeverity.critical,
        information: [
          if (failure.details != null) 'Details: ${failure.details}',
          'Code: ${failure.code}',
          'User Message: ${failure.userFriendlyMessage}',
        ],
      );

      // Set custom keys for better error categorization
      await FirebaseCrashlytics.instance.setCustomKey(
        'error_type',
        failure.runtimeType.toString(),
      );
      await FirebaseCrashlytics.instance.setCustomKey(
        'severity',
        failure.severity.name,
      );

      if (kDebugMode) {
        print('Sent to crash reporting: ${failure.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send to crash reporting: $e');
      }
    }
  }

  Future<void> _sendToAnalytics(Failure failure) async {
    try {
      final analytics = FirebaseAnalytics.instance;

      // Log the error as an event
      await analytics.logEvent(
        name: 'error_occurred',
        parameters: {
          'error_type': failure.runtimeType.toString(),
          'error_message': failure.message,
          'error_code': failure.code ?? 'unknown',
          'severity': failure.severity.name,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Set user properties if this is a critical error
      if (failure.severity == ErrorSeverity.critical) {
        await analytics.setUserProperty(
          name: 'last_critical_error',
          value: failure.message,
        );
      }

      if (kDebugMode) {
        print('Sent to analytics: ${failure.runtimeType}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send to analytics: $e');
      }
    }
  }

  Future<List<Map<String, dynamic>>> getRecentLogs({int limit = 50}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/$_logFileName');

      if (!await logFile.exists()) {
        return [];
      }

      final lines = await logFile.readAsLines();
      final recentLines = lines.reversed.take(limit).toList();

      return recentLines.map((line) {
        try {
          return jsonDecode(line) as Map<String, dynamic>;
        } catch (e) {
          return <String, dynamic>{
            'error': 'Failed to parse log entry',
            'raw': line,
          };
        }
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to read log file: $e');
      }
      return [];
    }
  }

  Future<void> clearLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/$_logFileName');
      final backupFile = File('${logFile.path}.backup');

      if (await logFile.exists()) {
        await logFile.delete();
      }
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clear logs: $e');
      }
    }
  }
}
