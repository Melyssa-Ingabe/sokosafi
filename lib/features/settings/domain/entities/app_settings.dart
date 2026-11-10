import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';

/// Preferences kept on the device and restored on every launch.
class AppSettings extends Equatable {
  const AppSettings({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.searchRadiusKm = defaultSearchRadiusKm,
    this.preferredPaymentMethod = PaymentMethod.mtnMomo,
  });

  static const int defaultSearchRadiusKm = 5;
  static const List<int> searchRadiusOptionsKm = [1, 3, 5, 10, 20];

  final bool isDarkMode;
  final bool notificationsEnabled;
  final int searchRadiusKm;
  final PaymentMethod preferredPaymentMethod;

  AppSettings copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    int? searchRadiusKm,
    PaymentMethod? preferredPaymentMethod,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
      preferredPaymentMethod:
          preferredPaymentMethod ?? this.preferredPaymentMethod,
    );
  }

  @override
  List<Object?> get props => [
    isDarkMode,
    notificationsEnabled,
    searchRadiusKm,
    preferredPaymentMethod,
  ];
}
