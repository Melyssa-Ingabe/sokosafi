import 'package:sokosafi/features/reviews/domain/entities/review.dart';
import 'package:sokosafi/features/reviews/domain/entities/review_target.dart';

/// Every method throws, or its stream emits, a ReviewFailure on error.
abstract interface class ReviewRepository {
  /// Every review a business has received.
  Stream<List<Review>> watchBusinessReviews(String businessId);

  /// Loads the customer's collected order and its business for rating.
  Future<ReviewTarget> loadTarget({
    required String orderId,
    required String customerId,
  });

  /// Saves the review. Refuses a second review for the same order.
  Future<void> submitReview({
    required ReviewTarget target,
    required String customerId,
    required int rating,
    required String comment,
  });
}
