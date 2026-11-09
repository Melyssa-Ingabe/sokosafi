import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_input.dart';

/// What the listings feature needs from storage. Firestore stays behind this
/// interface, so the BLoCs can be tested with a mock. Every method throws a
/// ListingFailure with a readable message when something goes wrong.
abstract interface class ListingRepository {
  /// Live list of one business's listings, newest first.
  Stream<List<Listing>> watchBusinessListings(String businessId);

  /// Returns the id of the new listing.
  Future<String> createListing({
    required String businessId,
    required ListingInput input,
  });

  Future<void> updateListing({
    required String listingId,
    required ListingInput input,
  });

  /// Refuses while customers still have paid orders waiting for pickup.
  Future<void> deleteListing({
    required String businessId,
    required String listingId,
  });
}
