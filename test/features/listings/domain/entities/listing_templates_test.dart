import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_templates.dart';

import '../../listing_test_data.dart';

void main() {
  test('keeps one template per product name, newest first', () {
    final newest = buildTestListing(id: 'newest');
    final olderSameName = buildTestListing(id: 'older');

    final templates = ListingTemplates.recent([newest, olderSameName]);

    expect(templates.map((listing) => listing.id), ['newest']);
  });

  test('returns at most six templates', () {
    final listings = List.generate(
      10,
      (index) => buildTestListing(id: 'listing-$index', title: 'Item $index'),
    );

    expect(ListingTemplates.recent(listings), hasLength(6));
  });
}
