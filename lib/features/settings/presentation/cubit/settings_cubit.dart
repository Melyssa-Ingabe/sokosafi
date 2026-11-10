import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';
import 'package:sokosafi/features/settings/data/repositories/settings_repository.dart';
import 'package:sokosafi/features/settings/domain/entities/app_settings.dart';

/// Holds the device preferences. Other features read them from here, for
/// example the feed reads [AppSettings.searchRadiusKm].
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repository) : super(_repository.load());

  final SettingsRepository _repository;

  Future<void> setDarkMode(bool isDarkMode) {
    return _update(state.copyWith(isDarkMode: isDarkMode));
  }

  Future<void> setNotificationsEnabled(bool isEnabled) {
    return _update(state.copyWith(notificationsEnabled: isEnabled));
  }

  Future<void> setSearchRadius(int kilometres) {
    if (!AppSettings.searchRadiusOptionsKm.contains(kilometres)) {
      return Future.value();
    }
    return _update(state.copyWith(searchRadiusKm: kilometres));
  }

  Future<void> setPreferredPaymentMethod(PaymentMethod method) {
    return _update(state.copyWith(preferredPaymentMethod: method));
  }

  Future<void> _update(AppSettings settings) async {
    emit(settings);
    await _repository.save(settings);
  }
}
