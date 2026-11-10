import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/orders/domain/entities/order_business.dart';
import 'package:sokosafi/features/orders/domain/entities/order_listing.dart';

class CheckoutItem extends Equatable {
  const CheckoutItem({required this.listing, required this.business});

  final OrderListing listing;
  final OrderBusiness business;

  @override
  List<Object?> get props => [listing, business];
}
