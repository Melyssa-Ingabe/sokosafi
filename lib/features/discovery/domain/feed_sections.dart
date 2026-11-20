import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_section.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

/// Turns the listings on sale into the rows of the customer feed.
abstract final class FeedSections {
  static const String endingSoonTitle = 'Ending soon';

  /// Listings whose pick-up time is this close count as ending soon.
  static const Duration endingSoonWindow = Duration(hours: 2);

  /// The "Ending soon" row stays short so the category rows stay visible.
  static const int endingSoonLimit = 6;

  /// Builds the rows: "Ending soon" first, then one row per category with
  /// the customer's food preferences first. Listings that can no longer be
  /// reserved are left out, and every row is sorted by soonest pick-up.
  static List<FeedSection> build({
    required List<FeedItem> items,
    required List<String> foodPreferences,
    required DateTime now,
  }) {
    final available = items.where((item) => item.isAvailableAt(now)).toList()
      ..sort((a, b) => a.listing.pickupBy.compareTo(b.listing.pickupBy));

    final endingSoon = available
        .where(
          (item) => item.listing.pickupBy.difference(now) <= endingSoonWindow,
        )
        .take(endingSoonLimit)
        .toList();

    return [
      if (endingSoon.isNotEmpty)
        FeedSection(title: endingSoonTitle, items: endingSoon),
      for (final category in categoryOrder(foodPreferences))
        if (_inCategory(available, category) case final items
            when items.isNotEmpty)
          FeedSection(title: category.label, items: items, category: category),
    ];
  }

  /// The customer's preferred categories in the order they picked them,
  /// then the rest. Names that are not a category are ignored rather than
  /// read as a default, so a stray value never promotes a row.
  static List<ListingCategory> categoryOrder(List<String> foodPreferences) {
    final preferred = <ListingCategory>[
      for (final name in foodPreferences)
        ...ListingCategory.values.where((category) => category.name == name),
    ];
    return [
      ...preferred.toSet(),
      ...ListingCategory.values.where(
        (category) => !preferred.contains(category),
      ),
    ];
  }

  static List<FeedItem> _inCategory(
    List<FeedItem> items,
    ListingCategory category,
  ) {
    return items.where((item) => item.listing.category == category).toList();
  }
}
