import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/business_settings/domain/entities/business_settings.dart';
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

  BusinessSettingsCubit buildCubit() => BusinessSettingsCubit(
    repository: repository,
    businessId: 'bakery',
    ownerId: 'owner-1',
  );

  setUp(() => repository = MockBusinessSettingsRepository());

  blocTest<BusinessSettingsCubit, BusinessSettingsState>(
    'a pickup window that ends before it starts is refused and not saved',
    build: buildCubit,
    seed: () => const BusinessSettingsState(
      status: BusinessSettingsStatus.ready,
      settings: settings,
    ),
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
    'a valid pickup window is saved with a confirmation',
    setUp: () => when(
      () => repository.updateSettings(
        'bakery',
        pickupStart: '17:00',
        pickupEnd: '21:00',
      ),
    ).thenAnswer((_) async {}),
    build: buildCubit,
    seed: () => const BusinessSettingsState(
      status: BusinessSettingsStatus.ready,
      settings: settings,
    ),
    act: (cubit) => cubit.setPickupWindow(start: '17:00', end: '21:00'),
    verify: (cubit) {
      expect(cubit.state.feedback?.message, 'Pickup window updated');
      expect(cubit.state.feedback?.isError, isFalse);
    },
  );

  blocTest<BusinessSettingsCubit, BusinessSettingsState>(
    'a failed save shows the reason politely',
    setUp: () =>
        when(() => repository.updateSettings('bakery', autoClose: true))
            .thenThrow(const BusinessSettingsFailure('You seem to be offline')),
    build: buildCubit,
    seed: () => const BusinessSettingsState(
      status: BusinessSettingsStatus.ready,
      settings: settings,
    ),
    act: (cubit) => cubit.setAutoClose(true),
    verify: (cubit) {
      expect(cubit.state.feedback?.message, 'You seem to be offline');
      expect(cubit.state.feedback?.isError, isTrue);
    },
  );
}
