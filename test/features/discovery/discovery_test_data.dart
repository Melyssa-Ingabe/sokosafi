import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_type.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';

/// Fixed "now" so time-based rules give the same result on every run.
final DateTime feedNow = DateTime(2026, 11, 19, 15);

Business buildBusiness({
  String id = 'biz-1',
  String name = 'Boulangerie de Kigali',
  bool acceptingOrders = true,
  double latitude = -1.9441,
  double longitude = 30.0619,
}) {
  return Business(
    id: id,
    ownerId: 'owner-$id',
    name: name,
    type: BusinessType.bakery,
    address: 'KG 5 Ave, Kacyiru',
    latitude: latitude,
    longitude: longitude,
    photoUrl: '',
    acceptingOrders: acceptingOrders,
    pickupStart: '17:00',
    pickupEnd: '20:00',
    autoClose: true,
    landmark: '',
    createdAt: feedNow.subtract(const Duration(days: 10)),
  );
}

/// A listing on sale from [business], with its pick-up time [pickupIn]
/// after [feedNow].
FeedItem buildFeedItem({
  String id = 'listing-1',
  ListingCategory category = ListingCategory.bakery,
  Duration pickupIn = const Duration(hours: 4),
  int quantity = 5,
  ListingStatus status = ListingStatus.active,
  Business? business,
}) {
  final owner = business ?? buildBusiness();
  return FeedItem(
    business: owner,
    listing: Listing(
      id: id,
      businessId: owner.id,
      title: 'Listing $id',
      description: 'Surplus from today',
      category: category,
      originalPrice: 3000,
      discountPrice: 1500,
      quantity: quantity,
      madeAt: feedNow.subtract(const Duration(hours: 2)),
      pickupBy: feedNow.add(pickupIn),
      imageUrl: '',
      instructions: '',
      status: status,
      createdAt: feedNow.subtract(const Duration(hours: 2)),
    ),
  );
}
