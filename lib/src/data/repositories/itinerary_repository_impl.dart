import 'package:dartz/dartz.dart';

import '../../core/database/hive_service.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/repositories/itinerary_repository.dart';
import '../models/itinerary_model.dart';

class ItineraryRepositoryImpl implements ItineraryRepository {
  final HiveService _hiveService;

  ItineraryRepositoryImpl({HiveService? hiveService})
    : _hiveService = hiveService ?? HiveService.instance;

  @override
  Future<Either<Failure, List<Itinerary>>> getAllItineraries() async {
    try {
      final itineraryModels = _hiveService.itinerariesBox.values.toList();
      final itineraries = itineraryModels
          .map((model) => model.toEntity())
          .toList();
      // Sort by creation date, newest first
      itineraries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(itineraries);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Itinerary?>> getItineraryById(int id) async {
    try {
      final itineraryModel = _hiveService.itinerariesBox.get(id);
      if (itineraryModel == null) {
        return const Right(null);
      }
      return Right(itineraryModel.toEntity());
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
      await _hiveService.itinerariesBox.put(itineraryModel.id, itineraryModel);
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
      await _hiveService.itinerariesBox.delete(id);
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
      await _hiveService.itinerariesBox.put(itineraryModel.id, itineraryModel);
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
      final itineraries = itineraryModels
          .map((model) => model.toEntity())
          .toList();
      // Sort by creation date, newest first
      itineraries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
        final updatedItinerary = itinerary.copyWith(isOfflineAvailable: true);
        await _hiveService.itinerariesBox.put(id, updatedItinerary);
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
