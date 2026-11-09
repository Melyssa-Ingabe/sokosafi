import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_input.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';

/// Fixed "now" so time-based rules give the same result on every run.
final DateTime testNow = DateTime(2026, 11, 9, 12);

const String testBusinessId = 'business-1';

Listing buildTestListing({
  String id = 'listing-1',
  String title = 'Fresh artisan breads',
  int quantity = 20,
  ListingStatus status = ListingStatus.active,
}) {
  return Listing(
    id: id,
    businessId: testBusinessId,
    title: title,
    description: 'Baguettes and sourdough from this morning',
    category: ListingCategory.bakery,
    originalPrice: 1000,
    discountPrice: 600,
    quantity: quantity,
    madeAt: testNow.subtract(const Duration(hours: 3)),
    pickupBy: testNow.add(const Duration(hours: 2)),
    imageUrl: '',
    instructions: 'Side entrance',
    status: status,
    createdAt: testNow.subtract(const Duration(hours: 1)),
  );
}

ListingInput buildTestInput({int quantity = 20, int discountPrice = 600}) {
  return ListingInput(
    title: 'Fresh artisan breads',
    description: 'Baguettes and sourdough from this morning',
    category: ListingCategory.bakery,
    originalPrice: 1000,
    discountPrice: discountPrice,
    quantity: quantity,
    madeAt: testNow.subtract(const Duration(hours: 3)),
    pickupBy: testNow.add(const Duration(hours: 2)),
    instructions: 'Side entrance',
  );
}
