import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/discovery/domain/entities/saved_merchant.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/repositories/saved_merchants_repository.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/saved_merchants_cubit.dart';

import '../discovery_test_data.dart';

class MockSavedMerchantsRepository extends Mock
    implements SavedMerchantsRepository {}

void main() {
  late MockSavedMerchantsRepository repository;
  late StreamController<List<SavedMerchant>> saved;

  final bakery = buildBusiness(id: 'bakery', name: 'Boulangerie de Kigali');
  final savedBakery = SavedMerchant(business: bakery, savedAt: feedNow);

  SavedMerchantsCubit buildCubit() =>
      SavedMerchantsCubit(repository: repository);

  setUp(() {
    repository = MockSavedMerchantsRepository();
    saved = StreamController<List<SavedMerchant>>();
    when(() => repository.watchSavedMerchants('nelly'))
        .thenAnswer((_) => saved.stream);
    when(
      () => repository.save(
        uid: any(named: 'uid'),
        businessId: any(named: 'businessId'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => repository.remove(
        uid: any(named: 'uid'),
        businessId: any(named: 'businessId'),
      ),
    ).thenAnswer((_) async {});
  });

  // Not awaited: closing a stream nobody listened to never completes.
  tearDown(() => unawaited(saved.close()));

  test('starts signed out with nothing saved', () {
    expect(buildCubit().state.status, SavedMerchantsStatus.signedOut);
  });

  blocTest<SavedMerchantsCubit, SavedMerchantsState>(
    'shows the signed-in customer\'s saved shops as they stream in',
    build: buildCubit,
    act: (cubit) async {
      cubit.watchFor('nelly');
      saved.add([savedBakery]);
      await Future<void>.delayed(Duration.zero);
    },
    verify: (cubit) {
      expect(cubit.state.status, SavedMerchantsStatus.ready);
      expect(cubit.state.isSaved('bakery'), isTrue);
    },
  );

  blocTest<SavedMerchantsCubit, SavedMerchantsState>(
    'clears the list when the customer logs out',
    build: buildCubit,
    act: (cubit) async {
      cubit.watchFor('nelly');
      saved.add([savedBakery]);
      await Future<void>.delayed(Duration.zero);
      cubit.watchFor(null);
    },
    verify: (cubit) => expect(cubit.state, const SavedMerchantsState()),
  );

  blocTest<SavedMerchantsCubit, SavedMerchantsState>(
    'saves a shop that is not saved yet and says so',
    build: buildCubit,
    act: (cubit) async {
      cubit.watchFor('nelly');
      saved.add(const []);
      await Future<void>.delayed(Duration.zero);
      await cubit.toggle(bakery);
    },
    verify: (cubit) {
      verify(() => repository.save(uid: 'nelly', businessId: 'bakery'))
          .called(1);
      verifyNever(
        () => repository.remove(
          uid: any(named: 'uid'),
          businessId: any(named: 'businessId'),
        ),
      );
    },
    expect: () => containsAllInOrder([
      isA<SavedMerchantsState>().having(
        (state) => state.feedback?.message,
        'feedback',
        'Saved Boulangerie de Kigali',
      ),
    ]),
  );

  blocTest<SavedMerchantsCubit, SavedMerchantsState>(
    'removes a shop that is already saved',
    build: buildCubit,
    act: (cubit) async {
      cubit.watchFor('nelly');
      saved.add([savedBakery]);
      await Future<void>.delayed(Duration.zero);
      await cubit.toggle(bakery);
    },
    verify: (_) =>
        verify(() => repository.remove(uid: 'nelly', businessId: 'bakery'))
            .called(1),
  );

  blocTest<SavedMerchantsCubit, SavedMerchantsState>(
    'shows a polite error when saving fails',
    setUp: () =>
        when(() => repository.save(uid: 'nelly', businessId: 'bakery'))
            .thenThrow(const DiscoveryFailure('You seem to be offline')),
    build: buildCubit,
    act: (cubit) async {
      cubit.watchFor('nelly');
      saved.add(const []);
      await Future<void>.delayed(Duration.zero);
      await cubit.toggle(bakery);
    },
    expect: () => containsAllInOrder([
      isA<SavedMerchantsState>()
          .having((state) => state.feedback?.isError, 'isError', isTrue)
          .having(
            (state) => state.feedback?.message,
            'message',
            'You seem to be offline',
          ),
    ]),
    verify: (cubit) => expect(cubit.state.pendingIds, isEmpty),
  );

  blocTest<SavedMerchantsCubit, SavedMerchantsState>(
    'ignores a second tap while the first save is still sending',
    setUp: () {
      final slowSave = Completer<void>();
      when(() => repository.save(uid: 'nelly', businessId: 'bakery'))
          .thenAnswer((_) => slowSave.future);
      addTearDown(slowSave.complete);
    },
    build: buildCubit,
    act: (cubit) async {
      cubit.watchFor('nelly');
      saved.add(const []);
      await Future<void>.delayed(Duration.zero);
      unawaited(cubit.toggle(bakery));
      unawaited(cubit.toggle(bakery));
    },
    verify: (_) =>
        verify(() => repository.save(uid: 'nelly', businessId: 'bakery'))
            .called(1),
  );

  test('does nothing when nobody is signed in', () async {
    final cubit = buildCubit();

    await cubit.toggle(bakery);

    verifyNever(
      () => repository.save(
        uid: any(named: 'uid'),
        businessId: any(named: 'businessId'),
      ),
    );
  });
}
