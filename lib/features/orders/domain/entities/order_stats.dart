import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/orders/domain/entities/order_details.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';

/// Profile numbers, always calculated from orders rather than stored.
class OrderStats extends Equatable {
  const OrderStats({
    required this.orderCount,
    required this.amountSaved,
    required this.mealsRescued,
  });

  factory OrderStats.from(List<OrderDetails> orders) {
    final kept = orders.where(
      (details) => details.order.status != OrderStatus.cancelled,
    );
    final collected = kept.where(
      (details) => details.order.status == OrderStatus.collected,
    );
    return OrderStats(
      orderCount: kept.length,
      amountSaved: kept.fold<num>(
        0,
        (sum, details) => sum + details.savedAmount,
      ),
      mealsRescued: collected.fold<int>(
        0,
        (sum, details) => sum + details.order.quantity,
      ),
    );
  }

  final int orderCount;
  final num amountSaved;
  final int mealsRescued;

  @override
  List<Object?> get props => [orderCount, amountSaved, mealsRescued];
}
