import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sokosafi/features/business_settings/data/repositories/firestore_business_settings_repository.dart';
import 'package:sokosafi/features/business_settings/domain/failures/business_settings_failure.dart';

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

  group('watchSettings', () {
    test('reads a business without a landmark as an empty landmark', () async {
      final settings = await repository.watchSettings('bakery').first;

      expect(settings.pickupStart, '17:30');
      expect(settings.landmark, isEmpty);
    });

    test('fills in default values for missing fields', () async {
      await firestore.collection('businesses').doc('cafe').set({
        'name': 'Kigali Delight Cafe',
      });

      final settings = await repository.watchSettings('cafe').first;

      expect(settings.acceptingOrders, isTrue);
      expect(settings.autoClose, isFalse);
      expect(settings.pickupStart, '08:00');
      expect(settings.pickupEnd, '20:00');
    });

    test('a missing business gives a polite failure', () {
      expect(
        repository.watchSettings('missing').first,
        throwsA(
          isA<BusinessSettingsFailure>().having(
            (failure) => failure.message,
            'message',
            'We could not find your business',
          ),
        ),
      );
    });
  });

  group('loadOwnerPhone', () {
    test('reads the phone from the owner\'s users document', () async {
      await firestore.collection('users').doc('owner-1').set({
        'phone': '0788123192',
      });

      expect(await repository.loadOwnerPhone('owner-1'), '0788123192');
    });

    test('gives an empty phone when the owner has none', () async {
      expect(await repository.loadOwnerPhone('nobody'), isEmpty);
    });
  });

  group('updateSettings', () {
    test('only writes the fields that changed', () async {
      await repository.updateSettings(
        'bakery',
        acceptingOrders: false,
        landmark: '  Green awning  ',
      );

      final saved =
          (await firestore.collection('businesses').doc('bakery').get())
              .data()!;
      expect(saved['acceptingOrders'], isFalse);
      expect(saved['landmark'], 'Green awning');
      expect(saved['pickupStart'], '17:30');
      expect(saved['name'], 'Boulangerie de Kigali');
    });

    test('saves the pickup window and auto-close together', () async {
      await repository.updateSettings(
        'bakery',
        autoClose: true,
        pickupStart: '16:00',
        pickupEnd: '19:00',
      );

      final saved =
          (await firestore.collection('businesses').doc('bakery').get())
              .data()!;
      expect(saved['autoClose'], isTrue);
      expect(saved['pickupStart'], '16:00');
      expect(saved['pickupEnd'], '19:00');
    });

    test('a business that does not exist gives a polite failure', () {
      expect(
        repository.updateSettings('missing', autoClose: true),
        throwsA(isA<BusinessSettingsFailure>()),
      );
    });
  });
}
