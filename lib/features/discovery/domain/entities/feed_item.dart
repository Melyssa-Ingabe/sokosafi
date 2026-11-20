import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';

/// A listing a customer can browse, together with the business that posted
/// it. The business is read from businesses, never copied into the listing.
class FeedItem extends Equatable {
  const FeedItem({required this.listing, required this.business});

  final Listing listing;
  final Business business;

  /// Whether a customer can still reserve it: on sale, with items left,
  /// before its pick-up time and from a business taking orders.
  bool isAvailableAt(DateTime now) {
    return listing.effectiveStatus(now) == ListingStatus.active &&
        listing.quantity > 0 &&
        business.acceptingOrders;
  }

  @override
  List<Object?> get props => [listing, business];
}
