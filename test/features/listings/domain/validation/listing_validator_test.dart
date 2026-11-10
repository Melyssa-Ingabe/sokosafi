import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/listings/domain/validation/listing_validator.dart';

void main() {
  final now = DateTime(2026, 11, 9, 12);

  group('discountPrice', () {
    test('rejects a discount higher than the original price', () {
      expect(
        ListingValidator.discountPrice('1200', original: '1000'),
        'Discount price must be lower than the original',
      );
    });

    test('rejects a discount equal to the original price', () {
      expect(
        ListingValidator.discountPrice('1000', original: '1000'),
        isNotNull,
      );
    });

    test('accepts a discount lower than the original price', () {
      expect(ListingValidator.discountPrice('600', original: '1000'), isNull);
    });

    test('rejects an empty or zero discount', () {
      expect(ListingValidator.discountPrice('', original: '1000'), isNotNull);
      expect(ListingValidator.discountPrice('0', original: '1000'), isNotNull);
    });
  });

  group('originalPrice', () {
    test('rejects text that is not a number', () {
      expect(ListingValidator.originalPrice('abc'), isNotNull);
    });

    test('accepts a price written with a thousands separator', () {
      expect(ListingValidator.originalPrice('1,000'), isNull);
      expect(ListingValidator.parsePrice('1,000'), 1000);
    });
  });

  group('quantity', () {
    test('rejects zero', () {
      expect(ListingValidator.quantity(0), 'Quantity must be at least 1');
    });

    test('accepts one', () {
      expect(ListingValidator.quantity(1), isNull);
    });
  });

  group('times', () {
    test('rejects a pick-up time in the past', () {
      expect(
        ListingValidator.pickupBy(
          now.subtract(const Duration(minutes: 1)),
          now: now,
        ),
        'Pick-up time must be in the future',
      );
    });

    test('accepts a pick-up time in the future', () {
      expect(
        ListingValidator.pickupBy(now.add(const Duration(hours: 1)), now: now),
        isNull,
      );
    });

    test('rejects a made-at time after the pick-up time', () {
      expect(
        ListingValidator.madeAt(
          now,
          pickupBy: now.subtract(const Duration(hours: 1)),
          now: now.add(const Duration(hours: 1)),
        ),
        isNotNull,
      );
    });

    test('rejects a made-at time in the future', () {
      expect(
        ListingValidator.madeAt(
          now.add(const Duration(hours: 1)),
          pickupBy: now.add(const Duration(hours: 3)),
          now: now,
        ),
        'Made-at time cannot be in the future',
      );
    });
  });

  group('text fields', () {
    test('rejects a blank title', () {
      expect(ListingValidator.title('   '), isNotNull);
    });

    test('rejects instructions over 120 characters', () {
      expect(ListingValidator.instructions('a' * 121), isNotNull);
      expect(ListingValidator.instructions(''), isNull);
    });
  });
}
