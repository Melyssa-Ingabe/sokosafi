import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/orders/data/models/pickup_code.dart';
import 'package:sokosafi/features/orders/data/repositories/firestore_orders_repository.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';
import 'package:sokosafi/features/orders/domain/failures/orders_failure.dart';

void main() {
  final now = DateTime(2026, 11, 9, 17);
  late FakeFirebaseFirestore firestore;
  late FirestoreOrdersRepository repository;

  Future<void> seedListing({int quantity = 3, String status = 'active'}) async {
    await firestore.collection('businesses').doc('bakery').set({
      'name': 'Boulangerie de Kigali',
      'address': 'KG 5 Ave, Kacyiru',
    });
    await firestore.collection('listings').doc('bread').set({
      'businessId': 'bakery',
      'title': 'Fresh Artisan Breads',
      'imageUrl': '',
      'originalPrice': 1000,
      'discountPrice': 600,
      'quantity': quantity,
      'pickupBy': Timestamp.fromDate(now.add(const Duration(hours: 2))),
      'status': status,
    });
  }

  Future<Map<String, dynamic>> listingData() async {
    final snapshot = await firestore.collection('listings').doc('bread').get();
    return snapshot.data()!;
  }

  Future<String> order({int quantity = 1}) {
    return repository.placeOrder(
      customerId: 'customer-1',
      listingId: 'bread',
      quantity: quantity,
      paymentMethod: PaymentMethod.mtnMomo,
    );
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreOrdersRepository(
      firestore: firestore,
      clock: () => now,
    );
  });

  test('loads the listing and its business for checkout', () async {
    await seedListing();

    final item = await repository.loadCheckoutItem('bread');

    expect(item.listing.title, 'Fresh Artisan Breads');
    expect(item.business.name, 'Boulangerie de Kigali');
  });

  group('placeOrder', () {
    test('creates a paid order and reduces the listing quantity', () async {
      await seedListing();

      final orderId = await order(quantity: 2);

      final saved = await firestore.collection('orders').doc(orderId).get();
      expect(saved.data(), containsPair('customerId', 'customer-1'));
      expect(saved.data(), containsPair('businessId', 'bakery'));
      expect(saved.data(), containsPair('total', 1200));
      expect(saved.data(), containsPair('status', 'paid'));
      expect(saved.data()!['pickupCode'], matches(PickupCode.pattern));
      expect(await listingData(), containsPair('quantity', 1));
    });

    test('marks the listing sold out when the last item goes', () async {
      await seedListing(quantity: 2);

      await order(quantity: 2);

      expect(await listingData(), containsPair('status', 'sold out'));
    });

    test('refuses more items than are left', () async {
      await seedListing(quantity: 1);

      await expectLater(
        order(quantity: 2),
        throwsA(
          isA<OrdersFailure>().having(
            (failure) => failure.message,
            'message',
            contains('Only 1 left'),
          ),
        ),
      );
      expect(await listingData(), containsPair('quantity', 1));
    });

    test('refuses a listing that is no longer active', () async {
      await seedListing(status: 'expired');

      await expectLater(order(), throwsA(isA<OrdersFailure>()));
      expect((await firestore.collection('orders').get()).docs, isEmpty);
    });
  });

  group('cancelOrder', () {
    test('cancels the order and puts the items back on sale', () async {
      await seedListing(quantity: 2);
      final orderId = await order(quantity: 2);

      await repository.cancelOrder(orderId);

      final saved = await firestore.collection('orders').doc(orderId).get();
      expect(saved.data(), containsPair('status', 'cancelled'));
      expect(await listingData(), containsPair('quantity', 2));
      expect(await listingData(), containsPair('status', 'active'));
    });

    test('refuses an order that was already collected', () async {
      await seedListing();
      final orderId = await order();
      await firestore.collection('orders').doc(orderId).update({
        'status': 'collected',
      });

      await expectLater(
        repository.cancelOrder(orderId),
        throwsA(isA<OrdersFailure>()),
      );
    });
  });

  test('streams a customer\'s orders joined with listing details', () async {
    await seedListing();
    await order(quantity: 2);

    final orders = await repository.watchCustomerOrders('customer-1').first;

    expect(orders, hasLength(1));
    expect(orders.single.title, 'Fresh Artisan Breads');
    expect(orders.single.businessName, 'Boulangerie de Kigali');
    expect(orders.single.order.status, OrderStatus.paid);
    expect(orders.single.savedAmount, 800);
  });
}
