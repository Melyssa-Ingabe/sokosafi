import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/discovery/data/repositories/firestore_saved_merchants_repository.dart';

import '../discovery_test_data.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreSavedMerchantsRepository repository;

  Future<void> addBusiness(String id, String name) {
    return firestore.collection('businesses').doc(id).set({
      'ownerId': 'owner-$id',
      'name': name,
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
  }

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreSavedMerchantsRepository(firestore: firestore);
    await addBusiness('bakery', 'Boulangerie de Kigali');
    await addBusiness('cafe', 'Cafe Kigali Bistro');
  });

  test('stores only savedAt, under the business id', () async {
    await repository.save(uid: 'nelly', businessId: 'bakery');

    final saved = await firestore
        .doc('users/nelly/savedMerchants/bakery')
        .get();
    expect(saved.data()!.keys, ['savedAt']);
  });

  test('lists saved businesses with their details', () async {
    await repository.save(uid: 'nelly', businessId: 'bakery');

    final merchants = await repository.watchSavedMerchants('nelly').first;

    expect(merchants.single.business.name, 'Boulangerie de Kigali');
  });

  test('lists the most recently saved first', () async {
    await firestore.doc('users/nelly/savedMerchants/bakery').set({
      'savedAt': Timestamp.fromDate(feedNow),
    });
    await firestore.doc('users/nelly/savedMerchants/cafe').set({
      'savedAt': Timestamp.fromDate(feedNow.add(const Duration(hours: 1))),
    });

    final merchants = await repository.watchSavedMerchants('nelly').first;

    expect(merchants.map((merchant) => merchant.business.id), [
      'cafe',
      'bakery',
    ]);
  });

  test('forgets a business once it is removed', () async {
    await repository.save(uid: 'nelly', businessId: 'bakery');
    await repository.remove(uid: 'nelly', businessId: 'bakery');

    expect(await repository.watchSavedMerchants('nelly').first, isEmpty);
  });

  test('skips a saved business that no longer exists', () async {
    await firestore.doc('users/nelly/savedMerchants/gone').set({
      'savedAt': Timestamp.fromDate(feedNow),
    });

    expect(await repository.watchSavedMerchants('nelly').first, isEmpty);
  });

  test('keeps each customer\'s list separate', () async {
    await repository.save(uid: 'nelly', businessId: 'bakery');

    expect(await repository.watchSavedMerchants('prince').first, isEmpty);
  });
}
