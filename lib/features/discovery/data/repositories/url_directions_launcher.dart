import 'package:flutter/services.dart';
import 'package:sokosafi/features/discovery/domain/repositories/directions_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens Google Maps directions to the shop. On Android the link opens the
/// Maps app when it is installed and the browser otherwise, so no API key
/// or in-app routing is needed.
class UrlDirectionsLauncher implements DirectionsLauncher {
  const UrlDirectionsLauncher();

  /// The universal Maps URL; Maps starts from the phone's own location.
  static Uri directionsUri({
    required double latitude,
    required double longitude,
  }) {
    return Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '$latitude,$longitude',
    });
  }

  @override
  Future<bool> openDirections({
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await launchUrl(
        directionsUri(latitude: latitude, longitude: longitude),
        mode: LaunchMode.externalApplication,
      );
    } on PlatformException {
      return false;
    }
  }
}
