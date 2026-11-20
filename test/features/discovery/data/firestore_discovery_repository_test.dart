import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/discovery/data/repositories/firestore_discovery_repository.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';

import '../discovery_test_data.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreDiscoveryRepository repository;

  Map<String, dynamic> listingData({
    required String businessId,
    required Duration pickupIn,
    String title = 'Croissants',
  }) {
    return {
      'businessId': businessId,
      'title': title,
      'description': '',
      'category': 'bakery',
      'originalPrice': 3000,
      'discountPrice': 1500,
      'quantity': 4,
      'madeAt': Timestamp.fromDate(feedNow),
      'pickupBy': Timestamp.fromDate(feedNow.add(pickupIn)),
      'imageUrl': '',
      'instructions': '',
      'status': 'active',
      'createdAt': Timestamp.fromDate(feedNow),
    };
  }

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreDiscoveryRepository(
      firestore: firestore,
      clock: () => feedNow,
    );
    await firestore.collection('businesses').doc('biz-1').set({
      'ownerId': 'owner-1',
      'name': 'Boulangerie de Kigali',
      'type': 'bakery',
      'address': 'KG 5 Ave',
      'lat': -1.9441,
      'lng': 30.0619,
      'photoUrl': '',
      'acceptingOrders': true,
      'pickupStart': '17:00',
      'pickupEnd': '20:00',
      'autoClose': true,
      'createdAt': Timestamp.fromDate(feedNow),
    });
  });

  group('watchFeed', () {
    test('returns each listing with the business that posted it', () async {
      await firestore
          .collection('listings')
          .doc('bread')
          .set(
            listingData(
              businessId: 'biz-1',
              pickupIn: const Duration(hours: 2),
            ),
          );

      final items = await repository.watchFeed().first;

      expect(items, hasLength(1));
      expect(items.single.listing.title, 'Croissants');
      expect(items.single.business.name, 'Boulangerie de Kigali');
    });

    test('leaves out listings whose pick-up time has passed', () async {
      await firestore
          .collection('listings')
          .doc('old')
          .set(
            listingData(
              businessId: 'biz-1',
              pickupIn: const Duration(hours: -1),
            ),
          );

      expect(await repository.watchFeed().first, isEmpty);
    });

    test('leaves out a listing whose business no longer exists', () async {
      await firestore
          .collection('listings')
          .doc('orphan')
          .set(
            listingData(businessId: 'gone', pickupIn: const Duration(hours: 1)),
          );

      expect(await repository.watchFeed().first, isEmpty);
    });

    test('lists the soonest pick-up first', () async {
      final listings = firestore.collection('listings');
      await listings
          .doc('late')
          .set(
            listingData(
              businessId: 'biz-1',
              title: 'Late',
              pickupIn: const Duration(hours: 5),
            ),
          );
      await listings
          .doc('early')
          .set(
            listingData(
              businessId: 'biz-1',
              title: 'Early',
              pickupIn: const Duration(hours: 1),
            ),
          );

      final items = await repository.watchFeed().first;

      expect(items.map((item) => item.listing.title), ['Early', 'Late']);
    });
  });

  group('watchShopItems', () {
    test('returns only that shop\'s listings', () async {
      final listings = firestore.collection('listings');
      await listings
          .doc('mine')
          .set(
            listingData(
              businessId: 'biz-1',
              pickupIn: const Duration(hours: 2),
            ),
          );
      await listings
          .doc('theirs')
          .set(
            listingData(
              businessId: 'biz-2',
              pickupIn: const Duration(hours: 2),
            ),
          );

      final items = await repository
          .watchShopItems(buildBusiness(id: 'biz-1'))
          .first;

      expect(items.map((item) => item.listing.id), ['mine']);
    });
  });

  group('watchItem', () {
    test('returns the listing and its business', () async {
      await firestore
          .collection('listings')
          .doc('bread')
          .set(
            listingData(
              businessId: 'biz-1',
              pickupIn: const Duration(hours: 2),
            ),
          );

      final item = await repository.watchItem('bread').first;

      expect(item.listing.id, 'bread');
      expect(item.business.id, 'biz-1');
    });

    test('explains when the listing was deleted', () async {
      expect(
        repository.watchItem('missing').first,
        throwsA(
          isA<DiscoveryFailure>().having(
            (failure) => failure.message,
            'message',
            'This food is no longer listed',
          ),
        ),
      );
    });
  });
}
