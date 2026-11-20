import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_section.dart';
import 'package:sokosafi/features/discovery/domain/feed_sections.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';

import '../discovery_test_data.dart';

void main() {
  List<String> idsIn(FeedSection section) =>
      section.items.map((item) => item.listing.id).toList();

  List<String?> titles(List<FeedSection> sections) =>
      sections.map((section) => section.title).toList();

  group('FeedSections.build', () {
    test('leaves out food that can no longer be reserved', () {
      final sections = FeedSections.build(
        items: [
          buildFeedItem(id: 'on-sale'),
          buildFeedItem(id: 'past-pickup', pickupIn: const Duration(hours: -1)),
          buildFeedItem(id: 'sold-out', status: ListingStatus.soldOut),
          buildFeedItem(id: 'none-left', quantity: 0),
          buildFeedItem(
            id: 'shop-closed',
            business: buildBusiness(id: 'closed', acceptingOrders: false),
          ),
        ],
        foodPreferences: const [],
        now: feedNow,
      );

      expect(sections, hasLength(1));
      expect(idsIn(sections.single), ['on-sale']);
    });

    test('puts food ending within two hours in an Ending soon row first', () {
      final sections = FeedSections.build(
        items: [
          buildFeedItem(id: 'later', pickupIn: const Duration(hours: 5)),
          buildFeedItem(id: 'soon', pickupIn: const Duration(minutes: 40)),
        ],
        foodPreferences: const [],
        now: feedNow,
      );

      expect(sections.first.title, FeedSections.endingSoonTitle);
      expect(idsIn(sections.first), ['soon']);
      expect(idsIn(sections[1]), ['soon', 'later']);
    });

    test('sorts every row by the soonest pick-up time', () {
      final sections = FeedSections.build(
        items: [
          buildFeedItem(id: 'c', pickupIn: const Duration(hours: 6)),
          buildFeedItem(id: 'a', pickupIn: const Duration(hours: 3)),
          buildFeedItem(id: 'b', pickupIn: const Duration(hours: 4)),
        ],
        foodPreferences: const [],
        now: feedNow,
      );

      expect(idsIn(sections.single), ['a', 'b', 'c']);
    });

    test('shows the customer\'s preferred categories first', () {
      final sections = FeedSections.build(
        items: [
          buildFeedItem(id: 'bread', category: ListingCategory.bakery),
          buildFeedItem(id: 'veg', category: ListingCategory.grocery),
          buildFeedItem(id: 'lunch', category: ListingCategory.meals),
        ],
        foodPreferences: const ['grocery', 'meals'],
        now: feedNow,
      );

      expect(titles(sections), ['Grocery', 'Meals', 'Bakery']);
    });

    test('skips categories with nothing on sale', () {
      final sections = FeedSections.build(
        items: [buildFeedItem(category: ListingCategory.cafe)],
        foodPreferences: const ['bakery'],
        now: feedNow,
      );

      expect(titles(sections), ['Café']);
    });

    test('returns no rows when nothing is on sale', () {
      final sections = FeedSections.build(
        items: const [],
        foodPreferences: const [],
        now: feedNow,
      );

      expect(sections, isEmpty);
    });
  });

  group('FeedSections.categoryOrder', () {
    test('ignores names that are not a category', () {
      expect(FeedSections.categoryOrder(const ['pizza', 'cafe', 'cafe']), [
        ListingCategory.cafe,
        ListingCategory.bakery,
        ListingCategory.meals,
        ListingCategory.grocery,
      ]);
    });
  });
}
