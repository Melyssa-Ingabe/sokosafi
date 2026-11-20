import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';

/// Listings for customers to browse. Streams update as soon as a listing
/// changes, for example when someone buys the last item. Errors arrive as
/// DiscoveryFailure.
abstract interface class DiscoveryRepository {
  /// Listings whose pick-up time has not passed yet, soonest first, each
  /// with its business.
  Stream<List<FeedItem>> watchFeed();

  /// One listing and its business, for the product detail screen.
  Stream<FeedItem> watchItem(String listingId);

  /// Every listing from [business], for "Explore surplus" on a saved shop.
  /// Whether each can still be reserved is checked on the phone.
  Stream<List<FeedItem>> watchShopItems(Business business);
}
