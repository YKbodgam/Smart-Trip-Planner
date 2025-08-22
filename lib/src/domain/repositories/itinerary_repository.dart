import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/itinerary.dart';

abstract class ItineraryRepository {
  Future<Either<Failure, List<Itinerary>>> getAllItineraries();
  Future<Either<Failure, Itinerary?>> getItineraryById(int id);
  Future<Either<Failure, Itinerary>> saveItinerary(Itinerary itinerary);
  Future<Either<Failure, void>> deleteItinerary(int id);
  Future<Either<Failure, Itinerary>> updateItinerary(Itinerary itinerary);
  Future<Either<Failure, List<Itinerary>>> getOfflineItineraries();
  Future<Either<Failure, void>> markItineraryOffline(int id);
  Future<Either<Failure, void>> clearCache();
}
