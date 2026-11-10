import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:sokosafi/features/business_setup/domain/entities/place.dart';
import 'package:sokosafi/features/business_setup/domain/failures/business_failure.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/location_repository.dart';

/// Location from the phone's GPS (geolocator) and addresses from the
/// phone's built-in geocoder.
class DeviceLocationRepository implements LocationRepository {
  DeviceLocationRepository({geocoding.Geocoding? geocoder})
    : _geocoder = geocoder ?? geocoding.Geocoding();

  final geocoding.Geocoding _geocoder;

  @override
  Future<Place> currentPlace() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const BusinessFailure(
        'Location is turned off. Turn it on or type your address instead',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const BusinessFailure(
        'Location permission was refused. You can type your address instead',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const BusinessFailure(
        'Location is blocked for SokoSafi. Allow it in your phone settings '
        'or type your address instead',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return await describe(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      throw const BusinessFailure(
        'We could not find your location. Move the map to place the pin',
      );
    }
  }

  @override
  Future<Place> describe({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await _geocoder.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isEmpty) {
        return Place(latitude: latitude, longitude: longitude);
      }
      final placemark = placemarks.first;
      return Place(
        latitude: latitude,
        longitude: longitude,
        street: _firstNonEmpty([placemark.street, placemark.thoroughfare]),
        neighborhood: _joinNonEmpty([
          _firstNonEmpty([
            placemark.subLocality,
            placemark.subAdministrativeArea,
          ]),
          placemark.locality,
        ]),
      );
    } catch (_) {
      // Address lookup is a nice extra; the pin position is what matters.
      return Place(latitude: latitude, longitude: longitude);
    }
  }

  @override
  Future<Place?> search(String address) async {
    try {
      final locations = await _geocoder.locationFromAddress(address);
      if (locations.isEmpty) return null;
      return await describe(
        latitude: locations.first.latitude,
        longitude: locations.first.longitude,
      );
    } catch (_) {
      return null;
    }
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  static String _joinNonEmpty(List<String?> values) {
    final parts = <String>[];
    for (final value in values) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty && !parts.contains(trimmed)) parts.add(trimmed);
    }
    return parts.join(', ');
  }
}
