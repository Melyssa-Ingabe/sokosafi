import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/orders/data/models/firestore_reading.dart';
import 'package:sokosafi/features/reviews/domain/entities/review.dart';
import 'package:sokosafi/features/reviews/domain/entities/review_target.dart';
import 'package:sokosafi/features/reviews/domain/failures/review_failure.dart';
import 'package:sokosafi/features/reviews/domain/repositories/review_repository.dart';

class FirestoreReviewRepository implements ReviewRepository {
  FirestoreReviewRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const Duration _timeout = Duration(seconds: 20);
  static const int maxCommentLength = 300;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection('reviews');

  @override
  Stream<List<Review>> watchBusinessReviews(String businessId) {
    return _reviews
        .where('businessId', isEqualTo: businessId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_toReview).toList())
        .handleError((Object error) => throw _toFailure(error));
  }

  @override
  Future<ReviewTarget> loadTarget({
    required String orderId,
    required String customerId,
  }) async {
    try {
      final orderSnapshot = await _firestore
          .collection('orders')
          .doc(orderId)
          .get()
          .timeout(_timeout);
      final order = orderSnapshot.data();
      if (order == null || order.readString('customerId') != customerId) {
        throw const ReviewFailure('We could not find this order');
      }
      if (order.readString('status') != 'collected') {
        throw const ReviewFailure(
          'You can rate this order once you have picked it up',
        );
      }
      final businessId = order.readString('businessId');
      final results = await Future.wait([
        _firestore.collection('businesses').doc(businessId).get(),
        _reviews.doc(orderId).get(),
      ]).timeout(_timeout);
      final business = results[0].data() ?? const <String, dynamic>{};
      return ReviewTarget(
        orderId: orderId,
        businessId: businessId,
        businessName: business.readString('name'),
        businessPhotoUrl: business.readString('photoUrl'),
        collectedAt: order.readDate('collectedAt'),
        alreadyReviewed: results[1].exists,
      );
    } catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<void> submitReview({
    required ReviewTarget target,
    required String customerId,
    required int rating,
    required String comment,
  }) async {
    if (rating < 1 || rating > 5) {
      throw const ReviewFailure('Choose between 1 and 5 stars');
    }
    // The review's id is the orderId, so a second review for the same
    // order would land on the same document. The transaction refuses it
    // instead of overwriting the first one.
    final reviewRef = _reviews.doc(target.orderId);
    try {
      await _firestore.runTransaction((transaction) async {
        final existing = await transaction.get(reviewRef);
        if (existing.exists) {
          throw const ReviewFailure('You have already rated this pickup');
        }
        transaction.set(reviewRef, {
          'orderId': target.orderId,
          'customerId': customerId,
          'businessId': target.businessId,
          'rating': rating,
          'comment': comment.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }, timeout: _timeout);
    } catch (error) {
      throw _toFailure(error);
    }
  }

  Review _toReview(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return Review(
      id: snapshot.id,
      orderId: data.readString('orderId'),
      customerId: data.readString('customerId'),
      businessId: data.readString('businessId'),
      rating: data.readInt('rating'),
      comment: data.readString('comment'),
      // A review saved a moment ago may not have its server time yet.
      createdAt: data.readDate('createdAt') ?? DateTime.now(),
    );
  }

  ReviewFailure _toFailure(Object error) {
    if (error is ReviewFailure) return error;
    if (error is TimeoutException) {
      return const ReviewFailure(
        'This is taking too long. Check your connection and try again',
      );
    }
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return const ReviewFailure('You can only rate your own pickups');
        case 'unavailable':
        case 'deadline-exceeded':
          return const ReviewFailure(
            'You seem to be offline. Check your connection and try again',
          );
      }
    }
    return const ReviewFailure(ReviewFailure.genericMessage);
  }
}
