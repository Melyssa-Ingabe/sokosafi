import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/orders/domain/entities/checkout_item.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';
import 'package:sokosafi/features/orders/domain/failures/orders_failure.dart';
import 'package:sokosafi/features/orders/domain/repositories/orders_repository.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required this._repository,
    required this._customerId,
    required this._listingId,
    required PaymentMethod preferredPaymentMethod,
  }) : super(CheckoutState(paymentMethod: preferredPaymentMethod));

  final OrdersRepository _repository;
  final String _customerId;
  final String _listingId;

  Future<void> load() async {
    emit(state.copyWith(status: CheckoutStatus.loading, clearError: true));
    try {
      final item = await _repository.loadCheckoutItem(_listingId);
      if (item.listing.quantityLeft < 1) {
        throw const OrdersFailure('This item is sold out');
      }
      emit(state.copyWith(status: CheckoutStatus.ready, item: item));
    } on OrdersFailure catch (failure) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }

  void increaseQuantity() {
    if (state.canIncrease) emit(state.copyWith(quantity: state.quantity + 1));
  }

  void decreaseQuantity() {
    if (state.canDecrease) emit(state.copyWith(quantity: state.quantity - 1));
  }

  void selectPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(paymentMethod: method));
  }

  Future<void> placeOrder() async {
    if (state.status != CheckoutStatus.ready || state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final orderId = await _repository.placeOrder(
        customerId: _customerId,
        listingId: _listingId,
        quantity: state.quantity,
        paymentMethod: state.paymentMethod,
      );
      emit(state.copyWith(isSubmitting: false, placedOrderId: orderId));
    } on OrdersFailure catch (failure) {
      emit(state.copyWith(isSubmitting: false, errorMessage: failure.message));
    }
  }
}
