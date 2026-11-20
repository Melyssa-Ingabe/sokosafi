import 'dart:math' as math;

/// Straight-line distance between two points on the map.
abstract final class GeoDistance {
  static const double _earthRadiusKm = 6371;

  /// Great-circle distance in kilometres (haversine formula). Close enough
  /// for "how far is this shop" across a city.
  static double kilometres({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) {
    final latitudeDelta = _radians(toLatitude - fromLatitude);
    final longitudeDelta = _radians(toLongitude - fromLongitude);
    final a =
        math.pow(math.sin(latitudeDelta / 2), 2) +
        math.cos(_radians(fromLatitude)) *
            math.cos(_radians(toLatitude)) *
            math.pow(math.sin(longitudeDelta / 2), 2);
    return 2 * _earthRadiusKm * math.asin(math.sqrt(a));
  }

  /// "350 m away" under a kilometre, otherwise "2.4 km away".
  static String label(double kilometres) {
    if (kilometres < 1) {
      final metres = (kilometres * 1000 / 10).round() * 10;
      return '$metres m away';
    }
    return '${kilometres.toStringAsFixed(1)} km away';
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
