import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/business_setup/data/repositories/firestore_business_repository.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_setup_input.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_type.dart';
import 'package:sokosafi/features/business_setup/domain/failures/business_failure.dart';

void main() {
  const ownerId = 'owner-1';
  const input = BusinessSetupInput(
    name: 'Boulangerie de Kigali',
    type: BusinessType.bakery,
    address: 'KG 5 Ave, Kacyiru',
    latitude: -1.9441,
    longitude: 30.0619,
  );

  late FakeFirebaseFirestore firestore;
  late FirestoreBusinessRepository repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreBusinessRepository(firestore: firestore);
    await firestore.collection('users').doc(ownerId).set({
      'name': 'Annie',
      'role': 'customer',
    });
  });

  test('creates the business with exactly the ERD fields', () async {
    final businessId = await repository.createBusiness(
      ownerId: ownerId,
      input: input,
    );

    final stored = await firestore
        .collection('businesses')
        .doc(businessId)
        .get();
    expect(stored.data()!.keys.toSet(), {
      'ownerId',
      'name',
      'type',
      'address',
      'lat',
      'lng',
      'photoUrl',
      'acceptingOrders',
      'pickupStart',
      'pickupEnd',
      'autoClose',
      'landmark',
      'createdAt',
    });
    expect(stored.data()!['type'], 'bakery');
    expect(stored.data()!['acceptingOrders'], isTrue);
  });

  test('switches the owner role to business in the same write', () async {
    await repository.createBusiness(ownerId: ownerId, input: input);

    final user = await firestore.collection('users').doc(ownerId).get();
    expect(user.data()!['role'], 'business');
  });

  test('refuses a second business for the same owner', () async {
    await repository.createBusiness(ownerId: ownerId, input: input);

    expect(
      () => repository.createBusiness(ownerId: ownerId, input: input),
      throwsA(
        isA<BusinessFailure>().having(
          (failure) => failure.message,
          'message',
          'You already have a business set up',
        ),
      ),
    );
  });

  test('streams null before setup and the business after', () async {
    expect(await repository.watchOwnedBusiness(ownerId).first, isNull);

    await repository.createBusiness(ownerId: ownerId, input: input);

    final business = await repository.watchOwnedBusiness(ownerId).first;
    expect(business?.name, 'Boulangerie de Kigali');
    expect(business?.type, BusinessType.bakery);
    expect(business?.latitude, -1.9441);
  });

  test('new businesses start with an empty landmark', () async {
    final businessId = await repository.createBusiness(
      ownerId: ownerId,
      input: input,
    );

    final stored = await firestore
        .collection('businesses')
        .doc(businessId)
        .get();
    expect(stored.data()!['landmark'], '');
  });

  test('loads a business saved before landmark existed', () async {
    // Written without a landmark field, like businesses created before
    // the field was added.
    await firestore.collection('businesses').add({
      'ownerId': ownerId,
      'name': 'Simba Center',
      'type': 'supermarket',
      'address': 'KN 4 Ave',
      'lat': -1.95,
      'lng': 30.06,
      'photoUrl': '',
      'acceptingOrders': true,
      'pickupStart': '08:00',
      'pickupEnd': '20:00',
      'autoClose': false,
    });

    final business = await repository.watchOwnedBusiness(ownerId).first;
    expect(business?.name, 'Simba Center');
    expect(business?.landmark, '');
  });
}
