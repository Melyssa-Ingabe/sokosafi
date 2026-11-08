import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/core/utils/formatters.dart';

void main() {
  group('Formatters.rwf', () {
    test('adds thousands separators', () {
      expect(Formatters.rwf(1000), '1,000 RWF');
      expect(Formatters.rwf(1234567), '1,234,567 RWF');
    });

    test('leaves small amounts unchanged', () {
      expect(Formatters.rwf(600), '600 RWF');
    });
  });

  group('Formatters.timeLeft', () {
    test('shows hours and minutes', () {
      expect(
        Formatters.timeLeft(const Duration(hours: 1, minutes: 20)),
        '1h 20m left',
      );
    });

    test('shows minutes only under an hour', () {
      expect(Formatters.timeLeft(const Duration(minutes: 5)), '5m left');
    });

    test('shows expired for a past deadline', () {
      expect(Formatters.timeLeft(const Duration(seconds: -1)), 'Expired');
    });
  });

  group('Formatters.discountPercent', () {
    test('calculates the percentage off', () {
      expect(Formatters.discountPercent(original: 1000, discounted: 600), 40);
    });

    test('returns zero when the original price is invalid', () {
      expect(Formatters.discountPercent(original: 0, discounted: 600), 0);
    });
  });
}
