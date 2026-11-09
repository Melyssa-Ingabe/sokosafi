import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';

/// One surplus-food listing, matching the listings collection in the ERD.
/// The business name is not stored here; it is read from businesses.
class Listing extends Equatable {
  const Listing({
    required this.id,
    required this.businessId,
    required this.title,
    required this.description,
    required this.category,
    required this.originalPrice,
    required this.discountPrice,
    required this.quantity,
    required this.madeAt,
    required this.pickupBy,
    required this.imageUrl,
    required this.instructions,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String businessId;
  final String title;
  final String description;
  final ListingCategory category;
  final int originalPrice;
  final int discountPrice;
  final int quantity;
  final DateTime madeAt;
  final DateTime pickupBy;
  final String imageUrl;
  final String instructions;
  final ListingStatus status;
  final DateTime createdAt;

  /// Nothing on the server flips a listing to expired when its pick-up time
  /// passes, so the app works it out when displaying the listing.
  ListingStatus effectiveStatus(DateTime now) {
    if (status == ListingStatus.active && !pickupBy.isAfter(now)) {
      return ListingStatus.expired;
    }
    return status;
  }

  @override
  List<Object?> get props => [
    id,
    businessId,
    title,
    description,
    category,
    originalPrice,
    discountPrice,
    quantity,
    madeAt,
    pickupBy,
    imageUrl,
    instructions,
    status,
    createdAt,
  ];
}
