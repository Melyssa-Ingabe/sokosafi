import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';

/// One document in the orders collection.
class CustomerOrder extends Equatable {
  const CustomerOrder({
    required this.id,
    required this.customerId,
    required this.businessId,
    required this.listingId,
    required this.quantity,
    required this.total,
    required this.pickupCode,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.collectedAt,
  });

  final String id;
  final String customerId;
  final String businessId;
  final String listingId;
  final int quantity;
  final num total;
  final String pickupCode;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? collectedAt;

  bool get isActive => status == OrderStatus.paid;

  @override
  List<Object?> get props => [
    id,
    customerId,
    businessId,
    listingId,
    quantity,
    total,
    pickupCode,
    paymentMethod,
    status,
    createdAt,
    collectedAt,
  ];
}
