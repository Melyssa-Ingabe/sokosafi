import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/listings/data/repositories/firestore_listing_repository.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';
import 'package:sokosafi/features/listings/domain/failures/listing_failure.dart';

import '../../listing_test_data.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreListingRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreListingRepository(firestore: firestore);
  });

  test('creates a listing with exactly the ERD fields', () async {
    final listingId = await repository.createListing(
      businessId: testBusinessId,
      input: buildTestInput(),
    );

    final stored = await firestore.collection('listings').doc(listingId).get();
    expect(stored.data()!.keys.toSet(), {
      'businessId',
      'title',
      'description',
      'category',
      'originalPrice',
      'discountPrice',
      'quantity',
      'madeAt',
      'pickupBy',
      'imageUrl',
      'instructions',
      'status',
      'createdAt',
    });
    expect(stored.data()!['status'], 'active');
    expect(stored.data()!['category'], 'bakery');
  });

  test('streams only the listings of the given business', () async {
    await repository.createListing(
      businessId: testBusinessId,
      input: buildTestInput(),
    );
    await repository.createListing(
      businessId: 'another-business',
      input: buildTestInput(),
    );

    final listings = await repository
        .watchBusinessListings(testBusinessId)
        .first;
    expect(listings, hasLength(1));
    expect(listings.single.businessId, testBusinessId);
    expect(listings.single.discountPrice, 600);
  });

  test('an update changes the fields and keeps the business', () async {
    final listingId = await repository.createListing(
      businessId: testBusinessId,
      input: buildTestInput(),
    );

    await repository.updateListing(
      listingId: listingId,
      input: buildTestInput(quantity: 5, discountPrice: 500),
    );

    final listings = await repository
        .watchBusinessListings(testBusinessId)
        .first;
    expect(listings.single.quantity, 5);
    expect(listings.single.discountPrice, 500);
    expect(listings.single.status, ListingStatus.active);
  });

  test('deletes a listing with no orders waiting', () async {
    final listingId = await repository.createListing(
      businessId: testBusinessId,
      input: buildTestInput(),
    );

    await repository.deleteListing(
      businessId: testBusinessId,
      listingId: listingId,
    );

    final stored = await firestore.collection('listings').doc(listingId).get();
    expect(stored.exists, isFalse);
  });

  test('refuses to delete while a paid order waits for pickup', () async {
    final listingId = await repository.createListing(
      businessId: testBusinessId,
      input: buildTestInput(),
    );
    await firestore.collection('orders').add({
      'businessId': testBusinessId,
      'listingId': listingId,
      'status': 'paid',
    });

    expect(
      () => repository.deleteListing(
        businessId: testBusinessId,
        listingId: listingId,
      ),
      throwsA(isA<ListingFailure>()),
    );
    final stored = await firestore.collection('listings').doc(listingId).get();
    expect(stored.exists, isTrue);
  });

  test('turns a missing document into a polite failure', () async {
    expect(
      () => repository.updateListing(
        listingId: 'does-not-exist',
        input: buildTestInput(),
      ),
      throwsA(isA<ListingFailure>()),
    );
  });
}
