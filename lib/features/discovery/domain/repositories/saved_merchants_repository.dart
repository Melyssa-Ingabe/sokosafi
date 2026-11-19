import 'package:sokosafi/features/discovery/domain/entities/saved_merchant.dart';

/// The customer's saved businesses. Errors arrive as DiscoveryFailure.
abstract interface class SavedMerchantsRepository {
  /// The customer's saved businesses, most recently saved first. Updates as
  /// soon as one is saved or removed, on this screen or any other.
  Stream<List<SavedMerchant>> watchSavedMerchants(String uid);

  Future<void> save({required String uid, required String businessId});

  Future<void> remove({required String uid, required String businessId});
}
