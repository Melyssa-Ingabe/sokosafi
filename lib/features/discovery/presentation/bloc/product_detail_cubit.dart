import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';

part 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({required this._repository, required this._listingId})
    : super(const ProductDetailState());

  final DiscoveryRepository _repository;
  final String _listingId;
  StreamSubscription<FeedItem>? _subscription;

  void watch() {
    _subscription?.cancel();
    emit(state.copyWith(status: ProductDetailStatus.loading));
    _subscription = _repository
        .watchItem(_listingId)
        .listen(
          (item) => emit(
            state.copyWith(
              status: ProductDetailStatus.ready,
              item: item,
              // Someone else may buy items while this screen is open, so
              // the picked quantity never stays above what is left.
              quantity: state.quantity.clamp(1, _atLeastOne(item)),
            ),
          ),
          onError: (Object error) => emit(
            state.copyWith(
              status: ProductDetailStatus.failure,
              errorMessage: error is DiscoveryFailure
                  ? error.message
                  : DiscoveryFailure.genericMessage,
            ),
          ),
        );
  }

  void increaseQuantity() {
    if (state.canIncrease) emit(state.copyWith(quantity: state.quantity + 1));
  }

  void decreaseQuantity() {
    if (state.canDecrease) emit(state.copyWith(quantity: state.quantity - 1));
  }

  static int _atLeastOne(FeedItem item) =>
      item.listing.quantity < 1 ? 1 : item.listing.quantity;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
