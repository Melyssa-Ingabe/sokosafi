import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/business_setup/domain/entities/place.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/location_repository.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_section.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/feed_sections.dart';
import 'package:sokosafi/features/discovery/domain/geo_distance.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';

part 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit({
    required this._repository,
    required this._locationRepository,
    required this._foodPreferences,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const FeedState());

  final DiscoveryRepository _repository;
  final LocationRepository _locationRepository;
  final DateTime Function() _clock;
  List<String> _foodPreferences;
  List<FeedItem> _items = const [];
  StreamSubscription<List<FeedItem>>? _subscription;

  static const String locationUnavailableMessage =
      'Allow location to see how far each shop is';

  void watch() {
    _subscription?.cancel();
    emit(state.copyWith(status: FeedStatus.loading));
    _subscription = _repository.watchFeed().listen(
      (items) {
        _items = items;
        _emitSections();
      },
      onError: (Object error) => emit(
        state.copyWith(
          status: FeedStatus.failure,
          errorMessage: error is DiscoveryFailure
              ? error.message
              : DiscoveryFailure.genericMessage,
        ),
      ),
    );
  }

  /// Distances are a bonus: when the phone cannot share its location the
  /// feed keeps working and only the distances are hidden.
  Future<void> locate() async {
    try {
      final place = await _locationRepository.currentPlace();
      emit(state.copyWith(userLocation: place, clearLocationMessage: true));
    } on Exception {
      emit(state.copyWith(locationMessage: locationUnavailableMessage));
    }
  }

  /// Re-orders the rows after the customer changes their food preferences.
  void updateFoodPreferences(List<String> foodPreferences) {
    _foodPreferences = foodPreferences;
    if (state.status == FeedStatus.ready) _emitSections();
  }

  void _emitSections() {
    emit(
      state.copyWith(
        status: FeedStatus.ready,
        sections: FeedSections.build(
          items: _items,
          foodPreferences: _foodPreferences,
          now: _clock(),
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
