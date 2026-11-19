import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/discovery/domain/entities/search_filter.dart';
import 'package:sokosafi/features/discovery/domain/search_results.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';

import '../discovery_test_data.dart';

void main() {
  // Kigali city centre, where the test businesses are by default.
  const kigali = CustomerLocation(latitude: -1.9441, longitude: 30.0619);

  final nearBakery = buildBusiness(id: 'near', name: 'Boulangerie de Kigali');
  // About 11 km south of the centre.
  final farCafe = buildBusiness(
    id: 'far',
    name: 'Cafe Kicukiro',
    latitude: -2.0441,
  );

  final bread = buildFeedItem(id: 'bread', business: nearBakery);
  final coffee = buildFeedItem(
    id: 'coffee',
    category: ListingCategory.cafe,
    business: farCafe,
  );

  List<String> ids(List<SearchResult> results) =>
      results.map((result) => result.item.listing.id).toList();

  List<SearchResult> search(SearchFilter filter, {CustomerLocation? from}) =>
      SearchResults.apply(
        items: [bread, coffee],
        filter: filter,
        now: feedNow,
        from: from,
      );

  test('an empty filter shows everything on sale', () {
    expect(ids(search(const SearchFilter())), ['bread', 'coffee']);
  });

  test('matches the shop name, ignoring case', () {
    expect(ids(search(const SearchFilter(query: 'BOULANGERIE'))), ['bread']);
  });

  test('matches the food title', () {
    expect(ids(search(const SearchFilter(query: 'listing coffee'))), [
      'coffee',
    ]);
  });

  test('every word has to match somewhere', () {
    expect(search(const SearchFilter(query: 'boulangerie coffee')), isEmpty);
  });

  test('filters by category', () {
    expect(ids(search(const SearchFilter(category: ListingCategory.cafe))), [
      'coffee',
    ]);
  });

  test('filters by the highest price', () {
    expect(search(const SearchFilter(maxPriceRwf: 1000)), isEmpty);
    expect(search(const SearchFilter(maxPriceRwf: 1500)), hasLength(2));
  });

  test('filters by distance once the location is known', () {
    expect(ids(search(const SearchFilter(radiusKm: 5), from: kigali)), [
      'bread',
    ]);
  });

  test('ignores the distance filter without a location', () {
    expect(search(const SearchFilter(radiusKm: 5)), hasLength(2));
  });

  test('sorts the nearest shop first when the location is known', () {
    final results = SearchResults.apply(
      items: [coffee, bread],
      filter: const SearchFilter(),
      now: feedNow,
      from: kigali,
    );

    expect(ids(results), ['bread', 'coffee']);
    expect(results.first.distanceKm, closeTo(0, 0.01));
  });

  test('never shows food that can no longer be reserved', () {
    final results = SearchResults.apply(
      items: [
        buildFeedItem(id: 'sold', status: ListingStatus.soldOut),
        buildFeedItem(id: 'past', pickupIn: const Duration(hours: -1)),
      ],
      filter: const SearchFilter(),
      now: feedNow,
    );

    expect(results, isEmpty);
  });
}
