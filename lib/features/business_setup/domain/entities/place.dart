import 'package:equatable/equatable.dart';

/// A point on the map with whatever the phone could tell us about it.
class Place extends Equatable {
  const Place({
    required this.latitude,
    required this.longitude,
    this.street = '',
    this.neighborhood = '',
  });

  final double latitude;
  final double longitude;

  /// For example "KG 5 Ave". Empty when the phone could not look it up.
  final String street;

  /// For example "Kacyiru, Kigali". Empty when unknown.
  final String neighborhood;

  @override
  List<Object?> get props => [latitude, longitude, street, neighborhood];
}
