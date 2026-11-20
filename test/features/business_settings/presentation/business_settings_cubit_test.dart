import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/business_settings/domain/entities/business_settings.dart';
import 'package:sokosafi/features/business_settings/domain/entities/payout_account.dart';
import 'package:sokosafi/features/business_settings/domain/failures/business_settings_failure.dart';
import 'package:sokosafi/features/business_settings/domain/repositories/business_settings_repository.dart';
import 'package:sokosafi/features/business_settings/presentation/bloc/business_settings_cubit.dart';

class MockBusinessSettingsRepository extends Mock
    implements BusinessSettingsRepository {}

void main() {
  late MockBusinessSettingsRepository repository;

  const settings = BusinessSettings(
    acceptingOrders: true,
    autoClose: false,
    pickupStart: '17:30',
    pickupEnd: '20:00',
    landmark: '',
  );

  const readyState = BusinessSettingsState(
    status: BusinessSettingsStatus.ready,
    settings: settings,
  );

  BusinessSettingsCubit buildCubit() => BusinessSettingsCubit(
    repository: repository,
    businessId: 'bakery',
    ownerId: 'owner-1',
  );

  // Lets the stream and the phone lookup reach the cubit.
  Future<void> letStreamsDeliver() => Future<void>.delayed(Duration.zero);

  setUp(() => repository = MockBusinessSettingsRepository());

  group('watch', () {
    blocTest<BusinessSettingsCubit, BusinessSettingsState>(
      'shows the live settings and the payout account from the phone',
      setUp: () {
        when(() => repository.watchSettings('bakery'))
            .thenAnswer((_) => Stream.value(settings));
        when(() => repository.loadOwnerPhone('owner-1'))
            .thenAnswer((_) async => '0788123192');
      },
      build: buildCubit,
      act: (cubit) async {
        cubit.watch();
        await letStreamsDeliver();
      },
      verify: (cubit) {
        expect(cubit.state.status, BusinessSettingsStatus.ready);
        expect(cubit.state.settings, settings);
        expect(
          cubit.state.payoutAccount,
          PayoutAccount.fromPhone('0788123192'),
        );
      },
    );

    blocTest<BusinessSettingsCubit, BusinessSettingsState>(
      'shows a polite message when the settings cannot load',
      setUp: () {
        when(() => repository.watchSettings('bakery')).thenAnswer(
          (_) => Stream.error(
            const BusinessSettingsFailure('We could not find your business'),
          ),
        );
        when(() => repository.loadOwnerPhone('owner-1'))
            .thenAnswer((_) async => '');
      },
      build: buildCubit,
      act: (cubit) async {
        cubit.watch();
        await letStreamsDeliver();
      },
      verify: (cubit) {
        expect(cubit.state.status, BusinessSettingsStatus.failure);
        expect(cubit.state.errorMessage, 'We could not find your business');
      },
    );

    blocTest<BusinessSettingsCubit, BusinessSettingsState>(
      'still works when the phone cannot load, with an empty payout',
      setUp: () {
        when(() => repository.watchSettings('bakery'))
            .thenAnswer((_) => Stream.value(settings));
        when(() => repository.loadOwnerPhone('owner-1'))
            .thenThrow(const BusinessSettingsFailure('You seem to be offline'));
      },
      build: buildCubit,
      act: (cubit) async {
        cubit.watch();
        await letStreamsDeliver();
      },
      verify: (cubit) {
        expect(cubit.state.status, BusinessSettingsStatus.ready);
        expect(cubit.state.payoutAccount?.maskedNumber, isEmpty);
      },
    );
  });

  group('accepting orders', () {
    blocTest<BusinessSettingsCubit, BusinessSettingsState>(
      'pausing orders saves and explains that listings are hidden',
      setUp: () => when(
        () => repository.updateSettings('bakery', acceptingOrders: false),
      ).thenAnswer((_) async {}),
      build: buildCubit,
      seed: () => readyState,
      act: (cubit) => cubit.setAcceptingOrders(false),
      verify: (cubit) => expect(
        cubit.state.feedback?.message,
        'Orders paused. Customers will not see your listings',
      ),
    );

    blocTest<BusinessSettingsCubit, BusinessSettingsState>(
      'turning orders back on confirms listings are visible',
      setUp: () =>
          when(() => repository.updateSettings('bakery', acceptingOrders: true))
              .thenAnswer((_) async {}),
      build: buildCubit,
      seed: () => readyState,
      act: (cubit) => cubit.setAcceptingOrders(true),
      verify: (cubit) => expect(
        cubit.state.feedback?.message,
        'Your listings are visible to customers again',
      ),
    );
  });

  group('pickup window', () {
    blocTest<BusinessSettingsCubit, BusinessSettingsState>(
      'a window that ends before it starts is refused and not saved',
      build: buildCubit,
      seed: () => readyState,
      act: (cubit) => cubit.setPickupWindow(start: '20:00', end: '17:30'),
      verify: (cubit) {
        expect(cubit.state.feedback?.isError, isTrue);
        verifyNever(
          () => repository.updateSettings(
            any(),
            pickupStart: any(named: 'pickupStart'),
            pickupEnd: any(named: 'pickupEnd'),
          ),
        );
      },
    );

    blocTest<BusinessSettingsCubit, BusinessSettingsState>(
      'a valid window is saved with a confirmation',
      setUp: () => when(
        () => repository.updateSettings(
          'bakery',
          pickupStart: '17:00',
          pickupEnd: '21:00',
        ),
      ).thenAnswer((_) async {}),
      build: buildCubit,
      seed: () => readyState,
      act: (cubit) => cubit.setPickupWindow(start: '17:00', end: '21:00'),
      verify: (cubit) {
        expect(cubit.state.feedback?.message, 'Pickup window updated');
        expect(cubit.state.feedback?.isError, isFalse);
      },
    );
  });

  group('landmark', () {
    blocTest<BusinessSettingsCubit, BusinessSettingsState>(
      'a landmark is saved with a confirmation',
      setUp: () => when(
        () => repository.updateSettings(
          'bakery',
          landmark: 'Green awning next to the pharmacy',
        ),
      ).thenAnswer((_) async {}),
      build: buildCubit,
      seed: () => readyState,
      act: (cubit) => cubit.setLandmark('Green awning next to the pharmacy'),
      verify: (cubit) =>
          expect(cubit.state.feedback?.message, 'Pickup landmark saved'),
    );

    blocTest<BusinessSettingsCubit, BusinessSettingsState>(
      'a landmark over 120 characters is refused and not saved',
      build: buildCubit,
      seed: () => readyState,
      act: (cubit) => cubit.setLandmark('a' * 121),
      verify: (cubit) {
        expect(cubit.state.feedback?.isError, isTrue);
        verifyNever(
          () => repository.updateSettings(
            any(),
            landmark: any(named: 'landmark'),
          ),
        );
      },
    );
  });

  blocTest<BusinessSettingsCubit, BusinessSettingsState>(
    'a failed save shows the reason politely',
    setUp: () =>
        when(() => repository.updateSettings('bakery', autoClose: true))
            .thenThrow(const BusinessSettingsFailure('You seem to be offline')),
    build: buildCubit,
    seed: () => readyState,
    act: (cubit) => cubit.setAutoClose(true),
    verify: (cubit) {
      expect(cubit.state.feedback?.message, 'You seem to be offline');
      expect(cubit.state.feedback?.isError, isTrue);
    },
  );
}
