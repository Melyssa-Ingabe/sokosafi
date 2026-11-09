import 'package:equatable/equatable.dart';

/// The listing fields the orders screens show. Read from the listings
/// collection, never copied into an order.
class OrderListing extends Equatable {
  const OrderListing({
    required this.id,
    required this.businessId,
    required this.title,
    required this.imageUrl,
    required this.originalPrice,
    required this.discountPrice,
    required this.quantityLeft,
    required this.pickupBy,
    required this.isActive,
  });

  final String id;
  final String businessId;
  final String title;
  final String imageUrl;
  final num originalPrice;
  final num discountPrice;
  final int quantityLeft;
  final DateTime pickupBy;
  final bool isActive;

  bool isAvailableAt(DateTime moment) =>
      isActive && quantityLeft > 0 && pickupBy.isAfter(moment);

  @override
  List<Object?> get props => [
    id,
    businessId,
    title,
    imageUrl,
    originalPrice,
    discountPrice,
    quantityLeft,
    pickupBy,
    isActive,
  ];
}
