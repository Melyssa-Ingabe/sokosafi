import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/discovery/domain/entities/search_filter.dart';
import 'package:sokosafi/features/discovery/domain/geo_distance.dart';

/// Where the customer is, as plain numbers so the search rules do not
/// depend on any location package.
class CustomerLocation extends Equatable {
  const CustomerLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

/// One search result and how far away its shop is, when known.
class SearchResult extends Equatable {
  const SearchResult({required this.item, this.distanceKm});

  final FeedItem item;
  final double? distanceKm;

  @override
  List<Object?> get props => [item, distanceKm];
}

/// Applies a [SearchFilter] to the listings on sale.
abstract final class SearchResults {
  static List<SearchResult> apply({
    required List<FeedItem> items,
    required SearchFilter filter,
    required DateTime now,
    CustomerLocation? from,
  }) {
    final words = filter.query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    final results = <SearchResult>[];
    for (final item in items) {
      if (!item.isAvailableAt(now)) continue;
      if (filter.category case final category?
          when item.listing.category != category) {
        continue;
      }
      if (filter.maxPriceRwf case final maxPrice?
          when item.listing.discountPrice > maxPrice) {
        continue;
      }
      if (!_matchesEveryWord(item, words)) continue;

      final distance = from == null
          ? null
          : GeoDistance.kilometres(
              fromLatitude: from.latitude,
              fromLongitude: from.longitude,
              toLatitude: item.business.latitude,
              toLongitude: item.business.longitude,
            );
      // Without a location the radius cannot be checked, so it is
      // ignored rather than hiding everything.
      if (filter.radiusKm case final radius?
          when distance != null && distance > radius) {
        continue;
      }
      results.add(SearchResult(item: item, distanceKm: distance));
    }

    // Nearest first when the location is known, like "Near you" in Figma;
    // otherwise whatever has to be collected soonest.
    results.sort(
      (a, b) => (a.distanceKm != null && b.distanceKm != null)
          ? a.distanceKm!.compareTo(b.distanceKm!)
          : a.item.listing.pickupBy.compareTo(b.item.listing.pickupBy),
    );
    return results;
  }

  /// "croissant kacyiru" finds croissants from a shop in Kacyiru: every
  /// word has to appear somewhere, in any order.
  static bool _matchesEveryWord(FeedItem item, List<String> words) {
    if (words.isEmpty) return true;
    final text = [
      item.listing.title,
      item.listing.description,
      item.listing.category.label,
      item.business.name,
      item.business.address,
    ].join(' ').toLowerCase();
    return words.every(text.contains);
  }
}
