import 'package:equatable/equatable.dart';

/// The business fields the orders screens show.
class OrderBusiness extends Equatable {
  const OrderBusiness({
    required this.id,
    required this.name,
    required this.address,
    this.latitude = 0,
    this.longitude = 0,
    this.phone = '',
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  /// Empty when the shop has not saved one.
  final String phone;

  @override
  List<Object?> get props => [id, name, address, latitude, longitude, phone];
}
