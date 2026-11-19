import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';

part 'shop_listings_state.dart';

/// The food one saved shop has on sale right now, for "Explore surplus".
class ShopListingsCubit extends Cubit<ShopListingsState> {
  ShopListingsCubit({
    required this._repository,
    required this._business,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(const ShopListingsState());

  final DiscoveryRepository _repository;
  final Business _business;
  final DateTime Function() _clock;
  StreamSubscription<List<FeedItem>>? _subscription;

  void watch() {
    _subscription?.cancel();
    emit(const ShopListingsState());
    _subscription = _repository.watchShopItems(_business).listen(
      (items) {
        // Same rule as the feed: on sale, items left, before pick-up.
        final now = _clock();
        final available =
            items.where((item) => item.isAvailableAt(now)).toList()..sort(
              (a, b) => a.listing.pickupBy.compareTo(b.listing.pickupBy),
            );
        emit(
          ShopListingsState(status: ShopListingsStatus.ready, items: available),
        );
      },
      onError: (Object error) => emit(
        ShopListingsState(
          status: ShopListingsStatus.failure,
          errorMessage: error is DiscoveryFailure
              ? error.message
              : DiscoveryFailure.genericMessage,
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
