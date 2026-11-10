import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_setup_input.dart';

/// What the app needs from the businesses collection. Throws a
/// BusinessFailure with a readable message when something goes wrong.
abstract interface class BusinessRepository {
  /// The business owned by this user, or null while they have none. One
  /// user owns zero or one business.
  Stream<Business?> watchOwnedBusiness(String ownerId);

  /// Creates the business and switches the owner's role to business in one
  /// write. Returns the new businessId.
  Future<String> createBusiness({
    required String ownerId,
    required BusinessSetupInput input,
  });
}
