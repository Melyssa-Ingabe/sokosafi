import 'package:sokosafi/features/business_settings/domain/entities/business_settings.dart';

/// Every method throws, or its stream emits, a BusinessSettingsFailure on
/// error.
abstract interface class BusinessSettingsRepository {
  Stream<BusinessSettings> watchSettings(String businessId);

  /// The owner's phone from their users document, used as the payout
  /// account.
  Future<String> loadOwnerPhone(String ownerId);

  /// Saves only the fields that are passed.
  Future<void> updateSettings(
    String businessId, {
    bool? acceptingOrders,
    bool? autoClose,
    String? pickupStart,
    String? pickupEnd,
    String? landmark,
  });
}
