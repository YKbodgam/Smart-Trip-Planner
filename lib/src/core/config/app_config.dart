import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

class AppConfig {
  static late Isar isar;

  static const String appName = 'Smart Trip Planner';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String apiKey = 'your-openai-api-key';

  // Database Configuration
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open([
      ItineraryModelSchema,
      UserModelSchema,
      ChatMessageModelSchema,
    ], directory: dir.path);
  }

  static Future<void> dispose() async {
    await isar.close();
  }
}
