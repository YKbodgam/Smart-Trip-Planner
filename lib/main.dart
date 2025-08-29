import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'src/core/config/app_config.dart';

Future<void> main() async {
  // Ensure Flutter engine is initialized before any async code
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Show splash screen until initialization is complete
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await dotenv.load();

    AppConfig.initialize();

    // 3. Initialize Firebase (only if enabled in config)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable crash collection
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    // 4. Lock orientation
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Remove splash and launch the app
    FlutterNativeSplash.remove();

    runApp(const ProviderScope(child: MyApp()));
  }
  //
  catch (e, stackTrace) {
    // ✅ Use logging instead of print for production
    debugPrint('❌ App initialization failed: $e\n$stackTrace');

    // Show fallback error screen
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: _ErrorScreen(error: e.toString())),
      ),
    );
  }
}

/// A simple widget for showing initialization errors
class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Configuration Error',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => main(), // simple retry
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
