import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_type.dart';

/// A business, matching the businesses collection in the ERD. Business
/// settings (acceptingOrders, pickup window, autoClose) are set to defaults
/// at setup and changed later from the business settings screen.
class Business extends Equatable {
  const Business({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.photoUrl,
    required this.acceptingOrders,
    required this.pickupStart,
    required this.pickupEnd,
    required this.autoClose,
    required this.landmark,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final BusinessType? type;
  final String address;
  final double latitude;
  final double longitude;
  final String photoUrl;
  final bool acceptingOrders;

  /// Daily pickup window as "HH:mm", for example "08:00".
  final String pickupStart;
  final String pickupEnd;
  final bool autoClose;

  /// Optional pickup guide, for example "Green awning next to the
  /// pharmacy". Set from business settings; empty until then.
  final String landmark;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    ownerId,
    name,
    type,
    address,
    latitude,
    longitude,
    photoUrl,
    acceptingOrders,
    pickupStart,
    pickupEnd,
    autoClose,
    landmark,
    createdAt,
  ];
}
