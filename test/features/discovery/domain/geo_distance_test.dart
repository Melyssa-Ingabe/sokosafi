import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/discovery/domain/geo_distance.dart';

void main() {
  group('GeoDistance.kilometres', () {
    test('is zero for the same point', () {
      expect(
        GeoDistance.kilometres(
          fromLatitude: -1.9441,
          fromLongitude: 30.0619,
          toLatitude: -1.9441,
          toLongitude: 30.0619,
        ),
        0,
      );
    });

    test('measures Kigali to Huye at about 80 km in a straight line', () {
      final distance = GeoDistance.kilometres(
        fromLatitude: -1.9441,
        fromLongitude: 30.0619,
        toLatitude: -2.5967,
        toLongitude: 29.7394,
      );

      expect(distance, closeTo(80.9, 1));
    });
  });

  group('GeoDistance.label', () {
    test('uses metres, rounded to 10, under a kilometre', () {
      expect(GeoDistance.label(0.347), '350 m away');
    });

    test('uses kilometres with one decimal from a kilometre up', () {
      expect(GeoDistance.label(2.44), '2.4 km away');
    });
  });
}
