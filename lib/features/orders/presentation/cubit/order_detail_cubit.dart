import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/orders/domain/entities/order_details.dart';
import 'package:sokosafi/features/orders/domain/failures/orders_failure.dart';
import 'package:sokosafi/features/orders/domain/repositories/orders_repository.dart';

part 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit({required this._repository, required this._orderId})
    : super(const OrderDetailState.loading());

  final OrdersRepository _repository;
  final String _orderId;
  StreamSubscription<OrderDetails>? _subscription;

  void watch() {
    _subscription?.cancel();
    emit(const OrderDetailState.loading());
    _subscription = _repository
        .watchOrder(_orderId)
        .listen(
          (details) => emit(OrderDetailState.ready(details)),
          onError: (Object error) => emit(
            OrderDetailState.failure(
              error is OrdersFailure
                  ? error.message
                  : OrdersFailure.genericMessage,
            ),
          ),
        );
  }

  Future<void> cancel() async {
    final current = state;
    if (current is! OrderDetailReady) return;
    emit(current.copyWith(isCancelling: true));
    try {
      await _repository.cancelOrder(_orderId);
    } on OrdersFailure catch (e) {
      if (state is OrderDetailReady) {
        emit((state as OrderDetailReady).copyWith(isCancelling: false));
      }
      _cancelError = e.message;
    }
  }

  String? consumeCancelError() {
    final error = _cancelError;
    _cancelError = null;
    return error;
  }

  String? _cancelError;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
