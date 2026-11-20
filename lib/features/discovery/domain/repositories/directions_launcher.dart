/// Hands the trip to the shop over to the phone's maps app. Kept behind an
/// interface so widgets can be tested without opening anything.
abstract interface class DirectionsLauncher {
  /// Returns false when no app or browser could open the directions.
  Future<bool> openDirections({
    required double latitude,
    required double longitude,
  });
}
