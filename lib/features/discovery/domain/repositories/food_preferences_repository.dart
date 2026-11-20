import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

/// Saves which food categories the customer likes, so the feed can show
/// them first. Throws a DiscoveryFailure with a readable message on error.
abstract interface class FoodPreferencesRepository {
  Future<void> save({
    required String uid,
    required Set<ListingCategory> categories,
  });
}
