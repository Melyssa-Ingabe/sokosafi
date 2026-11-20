import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/discovery/data/repositories/url_directions_launcher.dart';

void main() {
  test('points Google Maps directions at the shop', () {
    final uri = UrlDirectionsLauncher.directionsUri(
      latitude: -1.9441,
      longitude: 30.0619,
    );

    expect(uri.scheme, 'https');
    expect(uri.host, 'www.google.com');
    expect(uri.path, '/maps/dir/');
    expect(uri.queryParameters['api'], '1');
    expect(uri.queryParameters['destination'], '-1.9441,30.0619');
  });
}
