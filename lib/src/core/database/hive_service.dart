import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/itinerary_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/chat_message_model.dart';

class HiveService {
  static const String _itinerariesBoxName = 'itineraries';
  static const String _usersBoxName = 'users';
  static const String _chatMessagesBoxName = 'chat_messages';

  static HiveService? _instance;
  static HiveService get instance => _instance ??= HiveService._();

  HiveService._();

  Box<ItineraryModel>? _itinerariesBox;
  Box<UserModel>? _usersBox;
  Box<ChatMessageModel>? _chatMessagesBox;

  Box<ItineraryModel> get itinerariesBox {
    if (_itinerariesBox == null || !_itinerariesBox!.isOpen) {
      throw Exception('Itineraries box is not initialized');
    }
    return _itinerariesBox!;
  }

  Box<UserModel> get usersBox {
    if (_usersBox == null || !_usersBox!.isOpen) {
      throw Exception('Users box is not initialized');
    }
    return _usersBox!;
  }

  Box<ChatMessageModel> get chatMessagesBox {
    if (_chatMessagesBox == null || !_chatMessagesBox!.isOpen) {
      throw Exception('Chat messages box is not initialized');
    }
    return _chatMessagesBox!;
  }

  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register adapters
    Hive.registerAdapter(ItineraryModelAdapter());
    Hive.registerAdapter(ItineraryDayModelAdapter());
    Hive.registerAdapter(ItineraryItemModelAdapter());
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(UserPreferencesModelAdapter());
    Hive.registerAdapter(ChatMessageModelAdapter());
    Hive.registerAdapter(MessageMetadataModelAdapter());
    Hive.registerAdapter(MessageTypeAdapter());

    // Open boxes
    _itinerariesBox = await Hive.openBox<ItineraryModel>(_itinerariesBoxName);
    _usersBox = await Hive.openBox<UserModel>(_usersBoxName);
    _chatMessagesBox = await Hive.openBox<ChatMessageModel>(_chatMessagesBoxName);
  }

  Future<void> close() async {
    await _itinerariesBox?.close();
    await _usersBox?.close();
    await _chatMessagesBox?.close();
    await Hive.close();
  }

  Future<void> clearAll() async {
    await _itinerariesBox?.clear();
    await _usersBox?.clear();
    await _chatMessagesBox?.clear();
  }
}
