import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/discovery/data/repositories/firestore_food_preferences_repository.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreFoodPreferencesRepository repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreFoodPreferencesRepository(firestore: firestore);
    await firestore.doc('users/nelly').set({
      'name': 'Nelly',
      'foodPreferences': <String>['meals'],
    });
  });

  test('stores the category names in a stable order', () async {
    await repository.save(
      uid: 'nelly',
      categories: {ListingCategory.grocery, ListingCategory.bakery},
    );

    final user = await firestore.doc('users/nelly').get();
    expect(user.data()?['foodPreferences'], ['bakery', 'grocery']);
    // Only the preferences change; the rest of the profile stays.
    expect(user.data()?['name'], 'Nelly');
  });

  test('saving nothing clears the preferences', () async {
    await repository.save(uid: 'nelly', categories: {});

    final user = await firestore.doc('users/nelly').get();
    expect(user.data()?['foodPreferences'], isEmpty);
  });
}
