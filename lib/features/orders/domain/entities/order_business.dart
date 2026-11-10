import 'package:equatable/equatable.dart';

/// The business fields the orders screens show.
class OrderBusiness extends Equatable {
  const OrderBusiness({
    required this.id,
    required this.name,
    required this.address,
  });

  final String id;
  final String name;
  final String address;

  @override
  List<Object?> get props => [id, name, address];
}
