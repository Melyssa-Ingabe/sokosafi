part of 'my_orders_cubit.dart';

enum MyOrdersStatus { loading, ready, failure }

enum OrdersTab { active, past }

class MyOrdersState extends Equatable {
  const MyOrdersState({
    this.status = MyOrdersStatus.loading,
    this.orders = const [],
    this.tab = OrdersTab.active,
    this.expandedOrderId,
    this.cancellingOrderId,
    this.errorMessage,
    this.feedback,
  });

  final MyOrdersStatus status;
  final List<OrderDetails> orders;
  final OrdersTab tab;
  final String? expandedOrderId;
  final String? cancellingOrderId;

  /// Why the list could not load.
  final String? errorMessage;

  /// A one-off message for a SnackBar, such as a failed cancel.
  final OrdersFeedback? feedback;

  List<OrderDetails> get activeOrders =>
      orders.where((details) => details.order.isActive).toList();

  List<OrderDetails> get pastOrders =>
      orders.where((details) => !details.order.isActive).toList();

  List<OrderDetails> get visibleOrders =>
      tab == OrdersTab.active ? activeOrders : pastOrders;

  OrderStats get stats => OrderStats.from(orders);

  MyOrdersState copyWith({
    MyOrdersStatus? status,
    List<OrderDetails>? orders,
    OrdersTab? tab,
    String? expandedOrderId,
    bool clearExpanded = false,
    String? cancellingOrderId,
    bool clearCancelling = false,
    String? errorMessage,
    OrdersFeedback? feedback,
  }) {
    return MyOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      tab: tab ?? this.tab,
      expandedOrderId: clearExpanded
          ? null
          : (expandedOrderId ?? this.expandedOrderId),
      cancellingOrderId: clearCancelling
          ? null
          : (cancellingOrderId ?? this.cancellingOrderId),
      errorMessage: errorMessage,
      feedback: feedback,
    );
  }

  @override
  List<Object?> get props => [
    status,
    orders,
    tab,
    expandedOrderId,
    cancellingOrderId,
    errorMessage,
    feedback,
  ];
}

/// Not Equatable on purpose: the same message twice still counts as new,
/// so a BlocListener shows it again.
class OrdersFeedback {
  OrdersFeedback.error(this.message) : isError = true;
  OrdersFeedback.success(this.message) : isError = false;

  final String message;
  final bool isError;
}
