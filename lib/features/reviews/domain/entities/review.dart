import 'package:equatable/equatable.dart';

/// One document in the reviews collection. Its id is the orderId, which
/// is what keeps it to one review per order.
class Review extends Equatable {
  const Review({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.businessId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String orderId;
  final String customerId;
  final String businessId;

  /// 1 to 5 stars.
  final int rating;
  final String comment;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    orderId,
    customerId,
    businessId,
    rating,
    comment,
    createdAt,
  ];
}
