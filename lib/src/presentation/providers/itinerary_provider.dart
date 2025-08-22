import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/itinerary.dart';
import '../../domain/repositories/itinerary_repository.dart';
import '../providers/repository_providers.dart';

final itineraryListProvider =
    StateNotifierProvider<ItineraryListNotifier, ItineraryListState>((ref) {
      final repository = ref.watch(itineraryRepositoryProvider);
      return ItineraryListNotifier(repository);
    });

final itineraryDetailProvider =
    StateNotifierProvider.family<
      ItineraryDetailNotifier,
      ItineraryDetailState,
      int
    >((ref, id) {
      final repository = ref.watch(itineraryRepositoryProvider);
      return ItineraryDetailNotifier(repository, id);
    });

class ItineraryListNotifier extends StateNotifier<ItineraryListState> {
  final ItineraryRepository _repository;

  ItineraryListNotifier(this._repository)
    : super(const ItineraryListState.loading()) {
    loadItineraries();
  }

  Future<void> loadItineraries() async {
    state = const ItineraryListState.loading();

    final result = await _repository.getAllItineraries();
    result.fold(
      (failure) => state = ItineraryListState.error(failure.message),
      (itineraries) => state = ItineraryListState.loaded(itineraries),
    );
  }

  Future<void> loadOfflineItineraries() async {
    state = const ItineraryListState.loading();

    final result = await _repository.getOfflineItineraries();
    result.fold(
      (failure) => state = ItineraryListState.error(failure.message),
      (itineraries) => state = ItineraryListState.loaded(itineraries),
    );
  }

  Future<void> saveItinerary(Itinerary itinerary) async {
    final result = await _repository.saveItinerary(itinerary);
    result.fold(
      (failure) => state = ItineraryListState.error(failure.message),
      (savedItinerary) {
        // Reload the list
        loadItineraries();
      },
    );
  }

  Future<void> deleteItinerary(int id) async {
    final result = await _repository.deleteItinerary(id);
    result.fold(
      (failure) => state = ItineraryListState.error(failure.message),
      (_) {
        // Reload the list
        loadItineraries();
      },
    );
  }

  Future<void> markOffline(int id) async {
    final result = await _repository.markItineraryOffline(id);
    result.fold(
      (failure) => state = ItineraryListState.error(failure.message),
      (_) {
        // Reload the list
        loadItineraries();
      },
    );
  }
}

class ItineraryDetailNotifier extends StateNotifier<ItineraryDetailState> {
  final ItineraryRepository _repository;
  final int _itineraryId;

  ItineraryDetailNotifier(this._repository, this._itineraryId)
    : super(const ItineraryDetailState.loading()) {
    loadItinerary();
  }

  Future<void> loadItinerary() async {
    state = const ItineraryDetailState.loading();

    final result = await _repository.getItineraryById(_itineraryId);
    result.fold(
      (failure) => state = ItineraryDetailState.error(failure.message),
      (itinerary) {
        if (itinerary != null) {
          state = ItineraryDetailState.loaded(itinerary);
        } else {
          state = const ItineraryDetailState.error('Itinerary not found');
        }
      },
    );
  }

  Future<void> updateItinerary(Itinerary itinerary) async {
    final result = await _repository.updateItinerary(itinerary);
    result.fold(
      (failure) => state = ItineraryDetailState.error(failure.message),
      (updatedItinerary) =>
          state = ItineraryDetailState.loaded(updatedItinerary),
    );
  }
}

class ItineraryListState {
  const ItineraryListState();

  const factory ItineraryListState.loading() = _ItineraryListLoading;
  const factory ItineraryListState.loaded(List<Itinerary> itineraries) =
      _ItineraryListLoaded;
  const factory ItineraryListState.error(String message) = _ItineraryListError;
}

class _ItineraryListLoading extends ItineraryListState {
  const _ItineraryListLoading();
}

class _ItineraryListLoaded extends ItineraryListState {
  final List<Itinerary> itineraries;
  const _ItineraryListLoaded(this.itineraries);
}

class _ItineraryListError extends ItineraryListState {
  final String message;
  const _ItineraryListError(this.message);
}

class ItineraryDetailState {
  const ItineraryDetailState();

  const factory ItineraryDetailState.loading() = _ItineraryDetailLoading;
  const factory ItineraryDetailState.loaded(Itinerary itinerary) =
      _ItineraryDetailLoaded;
  const factory ItineraryDetailState.error(String message) =
      _ItineraryDetailError;
}

class _ItineraryDetailLoading extends ItineraryDetailState {
  const _ItineraryDetailLoading();
}

class _ItineraryDetailLoaded extends ItineraryDetailState {
  final Itinerary itinerary;
  const _ItineraryDetailLoaded(this.itinerary);
}

class _ItineraryDetailError extends ItineraryDetailState {
  final String message;
  const _ItineraryDetailError(this.message);
}
