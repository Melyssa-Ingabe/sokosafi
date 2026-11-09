import 'package:sokosafi/features/business_setup/domain/entities/place.dart';

/// Device location and address lookups. Throws a BusinessFailure with a
/// readable message, for example when location permission is refused.
abstract interface class LocationRepository {
  /// Asks for permission if needed, then returns where the phone is.
  Future<Place> currentPlace();

  /// Looks up the street and neighborhood for a point. Never throws: when
  /// the lookup fails it returns the point with empty text.
  Future<Place> describe({required double latitude, required double longitude});

  /// Finds a typed address on the map, or null when nothing matches.
  Future<Place?> search(String address);
}
