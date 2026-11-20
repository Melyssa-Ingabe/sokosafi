import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/discovery/data/repositories/discovery_error_mapper.dart';
import 'package:sokosafi/features/discovery/domain/repositories/food_preferences_repository.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

/// Writes users/{uid}.foodPreferences. The auth stream listens to the same
/// document, so the feed reorders as soon as the write lands.
class FirestoreFoodPreferencesRepository implements FoodPreferencesRepository {
  FirestoreFoodPreferencesRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const Duration _timeout = Duration(seconds: 20);

  @override
  Future<void> save({
    required String uid,
    required Set<ListingCategory> categories,
  }) async {
    // Stored in the enum's order so the same choice always saves the same
    // list. The security rules only accept these four names.
    final names = [
      for (final category in ListingCategory.values)
        if (categories.contains(category)) category.name,
    ];
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'foodPreferences': names})
          .timeout(_timeout);
    } on Object catch (error) {
      throw toDiscoveryFailure(error);
    }
  }
}
