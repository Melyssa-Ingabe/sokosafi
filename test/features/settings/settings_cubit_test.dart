import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';
import 'package:sokosafi/features/settings/data/repositories/settings_repository.dart';
import 'package:sokosafi/features/settings/domain/entities/app_settings.dart';
import 'package:sokosafi/features/settings/presentation/cubit/settings_cubit.dart';

void main() {
  Future<SettingsRepository> repositoryWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SettingsRepository(await SharedPreferences.getInstance());
  }

  test('starts with defaults when nothing is stored', () async {
    final cubit = SettingsCubit(await repositoryWith({}));

    expect(cubit.state, const AppSettings());
  });

  test('restores every stored preference', () async {
    final cubit = SettingsCubit(
      await repositoryWith({
        SettingsRepository.darkModeKey: true,
        SettingsRepository.notificationsKey: false,
        SettingsRepository.searchRadiusKey: 10,
        SettingsRepository.paymentMethodKey: 'airtelMoney',
      }),
    );

    expect(
      cubit.state,
      const AppSettings(
        isDarkMode: true,
        notificationsEnabled: false,
        searchRadiusKm: 10,
        preferredPaymentMethod: PaymentMethod.airtelMoney,
      ),
    );
  });

  test('ignores a stored radius that is not an option', () async {
    final cubit = SettingsCubit(
      await repositoryWith({SettingsRepository.searchRadiusKey: 7}),
    );

    expect(cubit.state.searchRadiusKm, AppSettings.defaultSearchRadiusKm);
  });

  group('changes survive a restart', () {
    late SettingsRepository repository;

    setUp(() async {
      repository = await repositoryWith({});
    });

    blocTest<SettingsCubit, AppSettings>(
      'dark mode',
      build: () => SettingsCubit(repository),
      act: (cubit) => cubit.setDarkMode(true),
      expect: () => [const AppSettings(isDarkMode: true)],
      verify: (_) => expect(repository.load().isDarkMode, isTrue),
    );

    blocTest<SettingsCubit, AppSettings>(
      'notifications',
      build: () => SettingsCubit(repository),
      act: (cubit) => cubit.setNotificationsEnabled(false),
      expect: () => [const AppSettings(notificationsEnabled: false)],
      verify: (_) => expect(repository.load().notificationsEnabled, isFalse),
    );

    blocTest<SettingsCubit, AppSettings>(
      'search radius',
      build: () => SettingsCubit(repository),
      act: (cubit) => cubit.setSearchRadius(20),
      expect: () => [const AppSettings(searchRadiusKm: 20)],
      verify: (_) => expect(repository.load().searchRadiusKm, 20),
    );

    blocTest<SettingsCubit, AppSettings>(
      'payment method',
      build: () => SettingsCubit(repository),
      act: (cubit) =>
          cubit.setPreferredPaymentMethod(PaymentMethod.airtelMoney),
      expect: () => [
        const AppSettings(preferredPaymentMethod: PaymentMethod.airtelMoney),
      ],
      verify: (_) => expect(
        repository.load().preferredPaymentMethod,
        PaymentMethod.airtelMoney,
      ),
    );

    blocTest<SettingsCubit, AppSettings>(
      'rejects a search radius that is not an option',
      build: () => SettingsCubit(repository),
      act: (cubit) => cubit.setSearchRadius(7),
      expect: () => <AppSettings>[],
    );
  });
}
