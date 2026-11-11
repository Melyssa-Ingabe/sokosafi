import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/business_orders/data/repositories/firestore_business_orders_repository.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreBusinessOrdersRepository repository;

  Future<void> seedOrder({
    String id = 'order-1',
    String businessId = 'bakery',
    String pickupCode = 'SKS-4A7F2B',
    String status = 'paid',
    DateTime? createdAt,
  }) {
    return firestore.collection('orders').doc(id).set({
      'customerId': 'customer-1',
      'businessId': businessId,
      'listingId': 'bread',
      'quantity': 2,
      'total': 1200,
      'pickupCode': pickupCode,
      'paymentMethod': 'mtnMomo',
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime(2026, 11, 10, 9)),
      'collectedAt': null,
    });
  }

  Future<Map<String, dynamic>> orderData(String id) async {
    final snapshot = await firestore.collection('orders').doc(id).get();
    return snapshot.data()!;
  }

  Matcher failsWith(String message) {
    return throwsA(
      isA<BusinessOrdersFailure>().having(
        (failure) => failure.message,
        'message',
        message,
      ),
    );
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreBusinessOrdersRepository(firestore: firestore);
  });

  group('confirmPickup', () {
    test('marks a paid order as collected', () async {
      await seedOrder();

      await repository.confirmPickup(
        businessId: 'bakery',
        pickupCode: 'SKS-4A7F2B',
      );

      final data = await orderData('order-1');
      expect(data['status'], 'collected');
      expect(data['collectedAt'], isNotNull);
    });

    test('accepts a lower-case code typed without the prefix', () async {
      await seedOrder();

      await repository.confirmPickup(
        businessId: 'bakery',
        pickupCode: '4a7f2b',
      );

      expect((await orderData('order-1'))['status'], 'collected');
    });

    test('rejects a code in the wrong format', () {
      expect(
        repository.confirmPickup(businessId: 'bakery', pickupCode: 'hello'),
        failsWith('Enter a code like SKS-4A7F2B'),
      );
    });

    test('rejects a code that belongs to another business', () async {
      await seedOrder(businessId: 'cafe');

      await expectLater(
        repository.confirmPickup(
          businessId: 'bakery',
          pickupCode: 'SKS-4A7F2B',
        ),
        failsWith('No order with this code at your business'),
      );
      expect((await orderData('order-1'))['status'], 'paid');
    });

    test('rejects an order that was already picked up', () async {
      await seedOrder(status: 'collected');

      await expectLater(
        repository.confirmPickup(
          businessId: 'bakery',
          pickupCode: 'SKS-4A7F2B',
        ),
        failsWith('This order was already picked up'),
      );
    });

    test('rejects a cancelled order', () async {
      await seedOrder(status: 'cancelled');

      await expectLater(
        repository.confirmPickup(
          businessId: 'bakery',
          pickupCode: 'SKS-4A7F2B',
        ),
        failsWith('This order was cancelled by the customer'),
      );
    });
  });

  group('watchOrders', () {
    test(
      'streams only this business\'s orders, newest first, with titles',
      () async {
        await firestore.collection('listings').doc('bread').set({
          'title': 'Fresh breads',
        });
        await seedOrder(id: 'older', createdAt: DateTime(2026, 11, 10, 8));
        await seedOrder(
          id: 'newer',
          pickupCode: 'SKS-2B3C4D',
          createdAt: DateTime(2026, 11, 10, 9),
        );
        await seedOrder(id: 'other-business', businessId: 'cafe');

        final orders = await repository.watchOrders('bakery').first;

        expect(orders.map((item) => item.order.id), ['newer', 'older']);
        expect(orders.first.listingTitle, 'Fresh breads');
      },
    );
  });
}
