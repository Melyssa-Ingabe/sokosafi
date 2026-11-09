import 'package:shared_preferences/shared_preferences.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';
import 'package:sokosafi/features/settings/domain/entities/app_settings.dart';

/// Reads and writes [AppSettings] with SharedPreferences.
class SettingsRepository {
  const SettingsRepository(this._preferences);

  final SharedPreferences _preferences;

  static const String darkModeKey = 'settings.darkMode';
  static const String notificationsKey = 'settings.notifications';
  static const String searchRadiusKey = 'settings.searchRadiusKm';
  static const String paymentMethodKey = 'settings.paymentMethod';

  AppSettings load() {
    const defaults = AppSettings();
    final storedRadius = _preferences.getInt(searchRadiusKey);
    return AppSettings(
      isDarkMode: _preferences.getBool(darkModeKey) ?? defaults.isDarkMode,
      notificationsEnabled:
          _preferences.getBool(notificationsKey) ??
          defaults.notificationsEnabled,
      searchRadiusKm: AppSettings.searchRadiusOptionsKm.contains(storedRadius)
          ? storedRadius!
          : defaults.searchRadiusKm,
      preferredPaymentMethod: PaymentMethod.fromName(
        _preferences.getString(paymentMethodKey),
      ),
    );
  }

  Future<void> save(AppSettings settings) async {
    await Future.wait([
      _preferences.setBool(darkModeKey, settings.isDarkMode),
      _preferences.setBool(notificationsKey, settings.notificationsEnabled),
      _preferences.setInt(searchRadiusKey, settings.searchRadiusKm),
      _preferences.setString(
        paymentMethodKey,
        settings.preferredPaymentMethod.name,
      ),
    ]);
  }
}
