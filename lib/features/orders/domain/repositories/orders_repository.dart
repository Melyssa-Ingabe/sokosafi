import 'package:sokosafi/features/orders/domain/entities/checkout_item.dart';
import 'package:sokosafi/features/orders/domain/entities/order_details.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';

/// Every method throws, or its stream emits, an OrdersFailure on error.
abstract interface class OrdersRepository {
  Future<CheckoutItem> loadCheckoutItem(String listingId);

  /// Reserves the items and creates the order in one transaction.
  /// Returns the new order id.
  Future<String> placeOrder({
    required String customerId,
    required String listingId,
    required int quantity,
    required PaymentMethod paymentMethod,
  });

  /// Newest first.
  Stream<List<OrderDetails>> watchCustomerOrders(String customerId);

  Stream<OrderDetails> watchOrder(String orderId);

  /// Cancels a paid order and puts its items back on sale.
  Future<void> cancelOrder(String orderId);
}
