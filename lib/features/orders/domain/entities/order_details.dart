import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/orders/domain/entities/customer_order.dart';
import 'package:sokosafi/features/orders/domain/entities/order_business.dart';
import 'package:sokosafi/features/orders/domain/entities/order_listing.dart';

/// An order joined with its listing and business. Either may be null when
/// the business deleted it after the order was placed.
class OrderDetails extends Equatable {
  const OrderDetails({required this.order, this.listing, this.business});

  final CustomerOrder order;
  final OrderListing? listing;
  final OrderBusiness? business;

  String get title => listing?.title ?? 'Item no longer listed';
  String get businessName => business?.name ?? 'Unknown business';

  num get originalTotal {
    final original = listing?.originalPrice;
    if (original == null) return order.total;
    return original * order.quantity;
  }

  num get savedAmount => originalTotal - order.total;

  @override
  List<Object?> get props => [order, listing, business];
}
