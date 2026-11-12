import 'package:equatable/equatable.dart';

/// What the Rate Experience screen needs about the order being rated.
/// The business name and photo are read from businesses, not stored on
/// the review.
class ReviewTarget extends Equatable {
  const ReviewTarget({
    required this.orderId,
    required this.businessId,
    required this.businessName,
    required this.businessPhotoUrl,
    required this.collectedAt,
    required this.alreadyReviewed,
  });

  final String orderId;
  final String businessId;
  final String businessName;
  final String businessPhotoUrl;
  final DateTime? collectedAt;
  final bool alreadyReviewed;

  @override
  List<Object?> get props => [
    orderId,
    businessId,
    businessName,
    businessPhotoUrl,
    collectedAt,
    alreadyReviewed,
  ];
}
