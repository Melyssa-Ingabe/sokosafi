import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/location_repository.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/discovery/domain/entities/search_filter.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:sokosafi/features/discovery/domain/search_results.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

part 'search_state.dart';

/// Search and filters over the listings on sale. Uses the same live stream
/// as the feed and filters on the phone, so typing never waits on the
/// network.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required this._repository,
    required this._locationRepository,
    int? defaultRadiusKm,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       _defaultRadiusKm = defaultRadiusKm,
       super(
         SearchState(
           filter: SearchFilter(radiusKm: defaultRadiusKm),
           defaultRadiusKm: defaultRadiusKm,
         ),
       );

  final DiscoveryRepository _repository;
  final LocationRepository _locationRepository;
  final DateTime Function() _clock;

  /// The search distance from settings, which "Clear filters" goes back to.
  final int? _defaultRadiusKm;
  List<FeedItem> _items = const [];
  StreamSubscription<List<FeedItem>>? _subscription;

  static const String locationUnavailableMessage =
      'Allow location to sort by distance and filter by how far shops are';

  void watch() {
    _subscription?.cancel();
    emit(state.copyWith(status: SearchStatus.loading));
    _subscription = _repository.watchFeed().listen(
      (items) {
        _items = items;
        _emitResults(state.copyWith(status: SearchStatus.ready));
      },
      onError: (Object error) => emit(
        state.copyWith(
          status: SearchStatus.failure,
          errorMessage: error is DiscoveryFailure
              ? error.message
              : DiscoveryFailure.genericMessage,
        ),
      ),
    );
  }

  /// Distances are optional: without them results are sorted by pick-up
  /// time and the distance filter is ignored.
  Future<void> locate() async {
    try {
      final place = await _locationRepository.currentPlace();
      _emitResults(
        state.copyWith(
          location: CustomerLocation(
            latitude: place.latitude,
            longitude: place.longitude,
          ),
          clearLocationMessage: true,
        ),
      );
    } on Exception {
      emit(state.copyWith(locationMessage: locationUnavailableMessage));
    }
  }

  void updateQuery(String query) =>
      _emitResults(state.copyWith(filter: state.filter.copyWith(query: query)));

  /// Null shows every category.
  void selectCategory(ListingCategory? category) => _emitResults(
    state.copyWith(
      filter: state.filter.copyWith(
        category: category,
        clearCategory: category == null,
      ),
    ),
  );

  /// From the filter sheet; null means "any".
  void applyLimits({int? maxPriceRwf, int? radiusKm}) => _emitResults(
    state.copyWith(
      filter: state.filter.copyWith(
        maxPriceRwf: maxPriceRwf,
        clearMaxPrice: maxPriceRwf == null,
        radiusKm: radiusKm,
        clearRadius: radiusKm == null,
      ),
    ),
  );

  /// Keeps the search text and goes back to the default filters.
  void clearFilters() => _emitResults(
    state.copyWith(
      filter: SearchFilter(
        query: state.filter.query,
        radiusKm: _defaultRadiusKm,
      ),
    ),
  );

  void _emitResults(SearchState next) {
    final now = _clock();
    emit(
      next.copyWith(
        results: SearchResults.apply(
          items: _items,
          filter: next.filter,
          now: now,
          from: next.location,
        ),
        availableCount: _items.where((item) => item.isAvailableAt(now)).length,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
