import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/database/firestore_service.dart';
import '../../core/database/hive_service.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/repositories/itinerary_repository.dart';
import '../models/itinerary_model.dart';

class ItineraryRepositoryImpl implements ItineraryRepository {
  final HiveService _hiveService;
  final FirestoreService _firestoreService;
  final Connectivity _connectivity;

  ItineraryRepositoryImpl({
    HiveService? hiveService,
    FirestoreService? firestoreService,
    Connectivity? connectivity,
  }) : _hiveService = hiveService ?? HiveService.instance,
       _firestoreService = firestoreService ?? FirestoreService.instance,
       _connectivity = connectivity ?? Connectivity();

  @override
  Future<Either<Failure, List<Itinerary>>> getAllItineraries() async {
    try {
      // Get local itineraries
      final localItineraries = _hiveService.itinerariesBox.values.toList();

      // If online, sync with cloud
      if (await _isOnline()) {
        final userId = await _getCurrentUserId();
        if (userId != null) {
          final cloudItineraries = await _firestoreService.getUserItineraries(
            userId,
          );

          // Update local storage with cloud data
          for (final itinerary in cloudItineraries) {
            await _hiveService.itinerariesBox.put(itinerary.id, itinerary);
          }

          // Return cloud data
          final itineraries =
              cloudItineraries.map((model) => model.toEntity()).toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return Right(itineraries);
        }
      }

      // Return local data if offline or no user
      final itineraries =
          localItineraries.map((model) => model.toEntity()).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(itineraries);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<String?> _getCurrentUserId() async {
    final userModels = _hiveService.usersBox.values.toList();
    if (userModels.isEmpty) return null;
    return userModels.first.uid;
  }

  @override
  Future<Either<Failure, Itinerary?>> getItineraryById(int id) async {
    try {
      // Try local first
      final localItinerary = _hiveService.itinerariesBox.get(id);

      // If online, check cloud for updates
      if (await _isOnline()) {
        final userId = await _getCurrentUserId();
        if (userId != null) {
          // Assuming id is convertible to string for cloud storage
          final cloudItinerary = await _firestoreService.getItineraryById(
            userId,
            id.toString(),
          );
          if (cloudItinerary != null) {
            // Update local with cloud data
            await _hiveService.itinerariesBox.put(id, cloudItinerary);
            return Right(cloudItinerary.toEntity());
          }
        }
      }

      return Right(localItinerary?.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Itinerary>> saveItinerary(Itinerary itinerary) async {
    try {
      final itineraryModel = ItineraryModel.fromEntity(itinerary);

      // Save locally
      await _hiveService.itinerariesBox.put(itineraryModel.id, itineraryModel);

      // If online, save to cloud
      if (await _isOnline()) {
        final userId = await _getCurrentUserId();
        if (userId != null) {
          await _firestoreService.saveItinerary(userId, itineraryModel);
        }
      }

      return Right(itineraryModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItinerary(int? id) async {
    try {
      // Delete locally
      await _hiveService.itinerariesBox.delete(id);

      // If online, delete from cloud
      if (await _isOnline()) {
        final userId = await _getCurrentUserId();
        if (userId != null && id != null) {
          await _firestoreService.deleteItinerary(userId, id.toString());
        }
      }

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Itinerary>> updateItinerary(
    Itinerary itinerary,
  ) async {
    try {
      final updatedItinerary = itinerary.copyWith(updatedAt: DateTime.now());
      final itineraryModel = ItineraryModel.fromEntity(updatedItinerary);

      // Update locally
      await _hiveService.itinerariesBox.put(itineraryModel.id, itineraryModel);

      // If online, update in cloud
      if (await _isOnline()) {
        final userId = await _getCurrentUserId();
        if (userId != null) {
          await _firestoreService.updateItinerary(userId, itineraryModel);
        }
      }

      return Right(itineraryModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Itinerary>>> getOfflineItineraries() async {
    try {
      final itineraryModels = _hiveService.itinerariesBox.values
          .where((model) => model.isOfflineAvailable)
          .toList();

      final itineraries =
          itineraryModels.map((model) => model.toEntity()).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Right(itineraries);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markItineraryOffline(int? id) async {
    try {
      final itinerary = _hiveService.itinerariesBox.get(id);
      if (itinerary != null) {
        final updatedItinerary = itinerary.copyWith(
          isOfflineAvailable: true,
          updatedAt: DateTime.now(),
        );

        // Update locally
        await _hiveService.itinerariesBox.put(id, updatedItinerary);

        // If online, update in cloud
        if (await _isOnline()) {
          final userId = await _getCurrentUserId();
          if (userId != null) {
            await _firestoreService.updateItinerary(userId, updatedItinerary);
          }
        }
      }
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await _hiveService.itinerariesBox.clear();
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
