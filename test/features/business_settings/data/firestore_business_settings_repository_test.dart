import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/business_settings/data/repositories/firestore_business_settings_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreBusinessSettingsRepository repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = FirestoreBusinessSettingsRepository(firestore: firestore);
    // Created before landmark existed, so it has no landmark field.
    await firestore.collection('businesses').doc('bakery').set({
      'name': 'Boulangerie de Kigali',
      'acceptingOrders': true,
      'autoClose': false,
      'pickupStart': '17:30',
      'pickupEnd': '20:00',
    });
  });

  test('reads a business without a landmark as an empty landmark', () async {
    final settings = await repository.watchSettings('bakery').first;

    expect(settings.pickupStart, '17:30');
    expect(settings.landmark, isEmpty);
  });

  test('only writes the fields that changed', () async {
    await repository.updateSettings(
      'bakery',
      acceptingOrders: false,
      landmark: '  Green awning  ',
    );

    final saved = (await firestore.collection('businesses').doc('bakery').get())
        .data()!;
    expect(saved['acceptingOrders'], isFalse);
    expect(saved['landmark'], 'Green awning');
    expect(saved['pickupStart'], '17:30');
    expect(saved['name'], 'Boulangerie de Kigali');
  });
}
