import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../error/exceptions.dart';
import '../../data/models/user_model.dart';
import '../../data/models/itinerary_model.dart';

class FirestoreService {
  static FirestoreService? _instance;
  static FirestoreService get instance => _instance ??= FirestoreService._();

  FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Collection Reference
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  // Itineraries Collection Reference (subcollection under user)
  CollectionReference<Map<String, dynamic>> _itinerariesCollection(
    String userId,
  ) => _usersCollection.doc(userId).collection('itineraries');

  // User Operations
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw DatabaseException(message: 'Failed to get user: $e');
    }
  }

  Future<UserModel> saveUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toJson());
      return user;
    } catch (e) {
      throw DatabaseException(message: 'Failed to save user: $e');
    }
  }

  Future<UserModel> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toJson());
      return user;
    } catch (e) {
      throw DatabaseException(message: 'Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      throw DatabaseException(message: 'Failed to delete user: $e');
    }
  }

  // Itinerary Operations
  Future<List<ItineraryModel>> getUserItineraries(String userId) async {
    try {
      final snapshot = await _itinerariesCollection(userId).get();
      return snapshot.docs
          .map((doc) => ItineraryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw DatabaseException(message: 'Failed to get itineraries: $e');
    }
  }

  Future<ItineraryModel?> getItineraryById(
    String userId,
    String itineraryId,
  ) async {
    try {
      final doc = await _itinerariesCollection(userId).doc(itineraryId).get();
      if (!doc.exists) return null;
      return ItineraryModel.fromJson(doc.data()!);
    } catch (e) {
      throw DatabaseException(message: 'Failed to get itinerary: $e');
    }
  }

  Future<ItineraryModel> saveItinerary(
    String userId,
    ItineraryModel itinerary,
  ) async {
    try {
      await _itinerariesCollection(
        userId,
      ).doc(itinerary.id).set(itinerary.toJson());
      return itinerary;
    } catch (e) {
      throw DatabaseException(message: 'Failed to save itinerary: $e');
    }
  }

  Future<ItineraryModel> updateItinerary(
    String userId,
    ItineraryModel itinerary,
  ) async {
    try {
      await _itinerariesCollection(
        userId,
      ).doc(itinerary.id).update(itinerary.toJson());
      return itinerary;
    } catch (e) {
      throw DatabaseException(message: 'Failed to update itinerary: $e');
    }
  }

  Future<void> deleteItinerary(String userId, String itineraryId) async {
    try {
      await _itinerariesCollection(userId).doc(itineraryId).delete();
    } catch (e) {
      throw DatabaseException(message: 'Failed to delete itinerary: $e');
    }
  }

  // Sync Operations
  Future<void> syncUserData(String userId) async {
    try {
      final user = await getUser(userId);
      if (user == null) return;

      final itineraries = await getUserItineraries(userId);

      final box = await Hive.openBox<UserModel>('users');
      await box.put(userId, user);

      final itinerariesBox = await Hive.openBox<ItineraryModel>('itineraries');
      for (final itinerary in itineraries) {
        await itinerariesBox.put('${userId}_${itinerary.id}', itinerary);
      }

      // Update sync timestamp
      final syncBox = await Hive.openBox<String>('sync');
      await syncBox.put('lastSync_$userId', DateTime.now().toIso8601String());
    } catch (e) {
      throw DatabaseException(message: 'Failed to sync user data: $e');
    }
  }
}
