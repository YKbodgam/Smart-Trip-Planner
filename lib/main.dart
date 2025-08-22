import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'src/core/config/app_config.dart';

void main() async {
  // Ensure Flutter engine is initialized before any async code
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Show splash screen until initialization is complete
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Load environment variables from .env file
  await dotenv.load();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize app configuration
  await AppConfig.initialize();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // Remove splash and launch the app
  FlutterNativeSplash.remove();

  runApp(ProviderScope(child: MyApp()));
}
