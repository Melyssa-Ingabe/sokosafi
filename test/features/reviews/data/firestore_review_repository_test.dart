import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/reviews/data/repositories/firestore_review_repository.dart';
import 'package:sokosafi/features/reviews/domain/failures/review_failure.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreReviewRepository repository;

  Future<void> seedOrder({String status = 'collected'}) async {
    await firestore.collection('businesses').doc('bakery').set({
      'name': 'Boulangerie de Kigali',
      'photoUrl': '',
    });
    await firestore.collection('orders').doc('order-1').set({
      'customerId': 'customer-1',
      'businessId': 'bakery',
      'status': status,
      'collectedAt': Timestamp.fromDate(DateTime(2026, 11, 11, 17, 45)),
    });
  }

  Matcher failsWith(String message) {
    return throwsA(
      isA<ReviewFailure>().having(
        (failure) => failure.message,
        'message',
        message,
      ),
    );
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreReviewRepository(firestore: firestore);
  });

  test('loads the collected order with its business name', () async {
    await seedOrder();

    final target = await repository.loadTarget(
      orderId: 'order-1',
      customerId: 'customer-1',
    );

    expect(target.businessName, 'Boulangerie de Kigali');
    expect(target.alreadyReviewed, isFalse);
  });

  test('refuses to rate an order that was not picked up yet', () async {
    await seedOrder(status: 'paid');

    expect(
      repository.loadTarget(orderId: 'order-1', customerId: 'customer-1'),
      failsWith('You can rate this order once you have picked it up'),
    );
  });

  test('saves the review under the order id', () async {
    await seedOrder();
    final target = await repository.loadTarget(
      orderId: 'order-1',
      customerId: 'customer-1',
    );

    await repository.submitReview(
      target: target,
      customerId: 'customer-1',
      rating: 5,
      comment: 'Quick handoff',
    );

    final saved = await firestore.collection('reviews').doc('order-1').get();
    expect(saved.data()?['rating'], 5);
    expect(saved.data()?['businessId'], 'bakery');
  });

  test('refuses a second review for the same order', () async {
    await seedOrder();
    final target = await repository.loadTarget(
      orderId: 'order-1',
      customerId: 'customer-1',
    );
    await repository.submitReview(
      target: target,
      customerId: 'customer-1',
      rating: 5,
      comment: '',
    );

    expect(
      repository.submitReview(
        target: target,
        customerId: 'customer-1',
        rating: 1,
        comment: '',
      ),
      failsWith('You have already rated this pickup'),
    );
  });
}
