part of 'business_orders_cubit.dart';

enum BusinessOrdersStatus { loading, ready, failure }

/// Incoming orders are paid and waiting to be picked up.
enum BusinessOrdersTab { incoming, completed, cancelled }

class BusinessOrdersState extends Equatable {
  const BusinessOrdersState({
    this.status = BusinessOrdersStatus.loading,
    this.orders = const [],
    this.tab = BusinessOrdersTab.incoming,
    this.errorMessage,
  });

  final BusinessOrdersStatus status;
  final List<BusinessOrder> orders;
  final BusinessOrdersTab tab;

  /// Why the list could not load.
  final String? errorMessage;

  List<BusinessOrder> ordersFor(BusinessOrdersTab tab) {
    final wantedStatus = switch (tab) {
      BusinessOrdersTab.incoming => OrderStatus.paid,
      BusinessOrdersTab.completed => OrderStatus.collected,
      BusinessOrdersTab.cancelled => OrderStatus.cancelled,
    };
    return orders.where((item) => item.order.status == wantedStatus).toList();
  }

  List<BusinessOrder> get visibleOrders => ordersFor(tab);

  BusinessOrdersState copyWith({
    BusinessOrdersStatus? status,
    List<BusinessOrder>? orders,
    BusinessOrdersTab? tab,
    String? errorMessage,
  }) {
    return BusinessOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      tab: tab ?? this.tab,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, tab, errorMessage];
}
