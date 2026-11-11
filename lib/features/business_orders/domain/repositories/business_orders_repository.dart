import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';

/// Orders seen from the business side. Every method throws, or its stream
/// emits, a BusinessOrdersFailure on error.
abstract interface class BusinessOrdersRepository {
  /// Every order for this business, newest first.
  Stream<List<BusinessOrder>> watchOrders(String businessId);

  /// Marks the paid order with this pickup code as collected.
  Future<void> confirmPickup({
    required String businessId,
    required String pickupCode,
  });
}
