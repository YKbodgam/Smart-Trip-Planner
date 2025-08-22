import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';

import '../../core/config/app_config.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/itinerary.dart';
import '../../domain/repositories/itinerary_repository.dart';
import '../models/itinerary_model.dart';

class ItineraryRepositoryImpl implements ItineraryRepository {
  final Isar _isar;

  ItineraryRepositoryImpl({Isar? isar}) : _isar = isar ?? AppConfig.isar;

  @override
  Future<Either<Failure, List<Itinerary>>> getAllItineraries() async {
    try {
      final itineraryModels = await _isar.itineraryModels.where().findAll();
      final itineraries = itineraryModels.map((model) => model.toEntity()).toList();
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
      final itineraryModel = await _isar.itineraryModels.get(id);
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
      await _isar.writeTxn(() async {
        await _isar.itineraryModels.put(itineraryModel);
      });
      return Right(itineraryModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItinerary(int id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.itineraryModels.delete(id);
      });
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Itinerary>> updateItinerary(Itinerary itinerary) async {
    try {
      final updatedItinerary = itinerary.copyWith(updatedAt: DateTime.now());
      final itineraryModel = ItineraryModel.fromEntity(updatedItinerary);
      await _isar.writeTxn(() async {
        await _isar.itineraryModels.put(itineraryModel);
      });
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
      final itineraryModels = await _isar.itineraryModels
          .where()
          .isOfflineAvailableEqualTo(true)
          .findAll();
      final itineraries = itineraryModels.map((model) => model.toEntity()).toList();
      return Right(itineraries);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markItineraryOffline(int id) async {
    try {
      await _isar.writeTxn(() async {
        final itinerary = await _isar.itineraryModels.get(id);
        if (itinerary != null) {
          final updatedItinerary = itinerary.copyWith(isOfflineAvailable: true);
          await _isar.itineraryModels.put(updatedItinerary);
        }
      });
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
      await _isar.writeTxn(() async {
        await _isar.itineraryModels.clear();
      });
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
