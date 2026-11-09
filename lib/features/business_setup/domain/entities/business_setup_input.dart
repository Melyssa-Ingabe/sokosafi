import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_type.dart';

/// What the owner fills in across the three setup steps.
class BusinessSetupInput extends Equatable {
  const BusinessSetupInput({
    required this.name,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.photoUrl = '',
  });

  final String name;
  final BusinessType type;
  final String address;
  final double latitude;
  final double longitude;
  final String photoUrl;

  BusinessSetupInput withPhotoUrl(String photoUrl) {
    return BusinessSetupInput(
      name: name,
      type: type,
      address: address,
      latitude: latitude,
      longitude: longitude,
      photoUrl: photoUrl,
    );
  }

  @override
  List<Object?> get props => [
    name,
    type,
    address,
    latitude,
    longitude,
    photoUrl,
  ];
}
