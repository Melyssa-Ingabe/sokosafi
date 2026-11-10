import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_type.dart';
import 'package:sokosafi/features/business_setup/domain/validation/business_validator.dart';

void main() {
  test('rejects a blank business name', () {
    expect(BusinessValidator.name('  '), 'Enter your business name');
    expect(BusinessValidator.name('Simba'), isNull);
  });

  test('requires a business type', () {
    expect(BusinessValidator.type(null), isNotNull);
    expect(BusinessValidator.type(BusinessType.hotel), isNull);
  });

  test('requires the pin to be placed', () {
    expect(
      BusinessValidator.location(latitude: null, longitude: 30),
      isNotNull,
    );
    expect(BusinessValidator.location(latitude: -1.9, longitude: 30), isNull);
  });

  group('fullAddress', () {
    test('adds the detected neighborhood to the typed address', () {
      expect(
        BusinessValidator.fullAddress(
          address: 'KG 5 Ave',
          neighborhood: 'Kacyiru, Kigali',
        ),
        'KG 5 Ave, Kacyiru, Kigali',
      );
    });

    test('does not repeat a neighborhood the owner already typed', () {
      expect(
        BusinessValidator.fullAddress(
          address: 'KG 5 Ave, Kacyiru',
          neighborhood: 'Kacyiru, Kigali',
        ),
        'KG 5 Ave, Kacyiru',
      );
    });

    test('keeps the typed address when no neighborhood was found', () {
      expect(
        BusinessValidator.fullAddress(address: ' KG 5 Ave ', neighborhood: ''),
        'KG 5 Ave',
      );
    });
  });
}
