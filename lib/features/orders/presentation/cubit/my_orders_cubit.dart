import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/orders/domain/entities/order_details.dart';
import 'package:sokosafi/features/orders/domain/entities/order_stats.dart';
import 'package:sokosafi/features/orders/domain/failures/orders_failure.dart';
import 'package:sokosafi/features/orders/domain/repositories/orders_repository.dart';

part 'my_orders_state.dart';

class MyOrdersCubit extends Cubit<MyOrdersState> {
  MyOrdersCubit({required this._repository, required this._customerId})
    : super(const MyOrdersState());

  final OrdersRepository _repository;
  final String _customerId;
  StreamSubscription<List<OrderDetails>>? _subscription;

  void watch() {
    _subscription?.cancel();
    emit(state.copyWith(status: MyOrdersStatus.loading));
    _subscription = _repository.watchCustomerOrders(_customerId).listen(
      (orders) {
        final isFirstLoad = state.status != MyOrdersStatus.ready;
        final next = state.copyWith(
          status: MyOrdersStatus.ready,
          orders: orders,
        );
        // Opens the newest active order once, on the first load, so a
        // later collapse is not undone by the next stream update.
        final latest = isFirstLoad ? next.latestActiveOrderId : null;
        emit(latest == null ? next : next.copyWith(expandedOrderId: latest));
      },
      onError: (Object error) => emit(
        state.copyWith(
          status: MyOrdersStatus.failure,
          errorMessage: error is OrdersFailure
              ? error.message
              : OrdersFailure.genericMessage,
        ),
      ),
    );
  }

  void selectTab(OrdersTab tab) {
    if (tab == state.tab) return;
    final latest = tab == OrdersTab.active ? state.latestActiveOrderId : null;
    emit(
      latest == null
          ? state.copyWith(tab: tab, clearExpanded: true)
          : state.copyWith(tab: tab, expandedOrderId: latest),
    );
  }

  void toggleExpanded(String orderId) {
    if (state.expandedOrderId == orderId) {
      emit(state.copyWith(clearExpanded: true));
    } else {
      emit(state.copyWith(expandedOrderId: orderId));
    }
  }

  Future<void> cancelOrder(String orderId) async {
    if (state.cancellingOrderId != null) return;
    emit(state.copyWith(cancellingOrderId: orderId));
    try {
      await _repository.cancelOrder(orderId);
      emit(
        state.copyWith(
          clearCancelling: true,
          feedback: OrdersFeedback.success('Order cancelled'),
        ),
      );
    } on OrdersFailure catch (failure) {
      emit(
        state.copyWith(
          clearCancelling: true,
          feedback: OrdersFeedback.error(failure.message),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
