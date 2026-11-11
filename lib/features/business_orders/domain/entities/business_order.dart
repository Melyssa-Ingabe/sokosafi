import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/orders/domain/entities/customer_order.dart';

/// An order as the business sees it: the order plus the title of the

class BusinessOrder extends Equatable {
  const BusinessOrder({required this.order, required this.listingTitle});

  final CustomerOrder order;

  /// Empty when the listing has since been deleted.
  final String listingTitle;

  @override
  List<Object?> get props => [order, listingTitle];
}
