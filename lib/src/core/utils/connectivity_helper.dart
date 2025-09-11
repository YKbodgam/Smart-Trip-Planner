import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static List<ConnectivityResult> _lastResults = [];
  static final List<Function(bool)> _listeners = [];

  static bool _initialized = false;

  // Initialize connectivity monitoring
  static Future<void> initialize() async {
    if (_initialized) return;

    // Get initial connectivity status
    _lastResults = await _connectivity.checkConnectivity();

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _lastResults = results;

      // Notify all listeners
      final isOnline = _hasConnectivity(results);
      for (final listener in _listeners) {
        listener(isOnline);
      }
    });

    _initialized = true;
  }

  // Check if device is currently online
  static Future<bool> isOnline() async {
    if (!_initialized) {
      await initialize();
    }

    return _hasConnectivity(_lastResults);
  }

  // Helper method to check if there is connectivity
  static bool _hasConnectivity(List<ConnectivityResult> results) {
    // If there's any connection that isn't 'none', we consider it online
    return results.any((result) => result != ConnectivityResult.none);
  }

  // Add a listener for connectivity changes
  static void addListener(Function(bool) listener) {
    if (!_initialized) {
      initialize();
    }

    _listeners.add(listener);

    // Immediately notify with current status
    if (_initialized) {
      listener(_hasConnectivity(_lastResults));
    }
  }

  // Remove a listener
  static void removeListener(Function(bool) listener) {
    _listeners.remove(listener);
  }

  // Dispose connectivity subscription
  static void dispose() {
    _subscription?.cancel();
    _listeners.clear();
    _initialized = false;
  }
}
