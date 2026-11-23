import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/bloc/feedback_message.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';
import 'package:sokosafi/features/business_orders/domain/repositories/business_orders_repository.dart';

/// The tick and cross on an order: mark it picked up, or cancel it.
class OrderActionsCubit extends Cubit<OrderActionsState> {
  OrderActionsCubit({required this._repository, required this._businessId})
    : super(const OrderActionsState());

  final BusinessOrdersRepository _repository;
  final String _businessId;

  /// Uses the order's own pickup code, so the owner does not have to scan
  /// it when the customer is standing at the counter.
  Future<void> confirm(BusinessOrder item) => _run(
    item,
    () => _repository.confirmPickup(
      businessId: _businessId,
      pickupCode: item.order.pickupCode,
    ),
    'Pickup confirmed. The order is now collected',
  );

  Future<void> cancel(BusinessOrder item) => _run(
    item,
    () => _repository.cancelOrder(
      businessId: _businessId,
      orderId: item.order.id,
    ),
    'Order cancelled. The portions are back on sale',
  );

  Future<void> _run(
    BusinessOrder item,
    Future<void> Function() action,
    String successMessage,
  ) async {
    // One order at a time, so a double tap cannot send the change twice.
    if (state.busyOrderId != null) return;
    emit(OrderActionsState(busyOrderId: item.order.id));
    try {
      await action();
      emit(
        OrderActionsState(feedback: FeedbackMessage.success(successMessage)),
      );
    } on BusinessOrdersFailure catch (failure) {
      emit(OrderActionsState(feedback: FeedbackMessage.error(failure.message)));
    }
  }
}

class OrderActionsState extends Equatable {
  const OrderActionsState({this.busyOrderId, this.feedback});

  /// The order whose change is being saved.
  final String? busyOrderId;
  final FeedbackMessage? feedback;

  @override
  List<Object?> get props => [busyOrderId, feedback];
}
