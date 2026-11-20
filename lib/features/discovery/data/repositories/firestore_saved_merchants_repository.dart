import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/business_setup/data/models/business_model.dart';
import 'package:sokosafi/features/discovery/data/repositories/discovery_error_mapper.dart';
import 'package:sokosafi/features/discovery/domain/entities/saved_merchant.dart';
import 'package:sokosafi/features/discovery/domain/repositories/saved_merchants_repository.dart';

class FirestoreSavedMerchantsRepository implements SavedMerchantsRepository {
  FirestoreSavedMerchantsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const Duration _timeout = Duration(seconds: 20);

  CollectionReference<Map<String, dynamic>> _savedMerchants(String uid) =>
      _firestore.collection('users').doc(uid).collection('savedMerchants');

  @override
  Stream<List<SavedMerchant>> watchSavedMerchants(String uid) {
    return _savedMerchants(uid)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          // The document id is the business id, so each saved business is
          // read from businesses rather than copied into the saved list.
          final businesses = await Future.wait(
            snapshot.docs.map(
              (doc) => _firestore.collection('businesses').doc(doc.id).get(),
            ),
          ).timeout(_timeout);
          return [
            for (final (index, business) in businesses.indexed)
              // A business deleted since it was saved is skipped.
              if (business.exists)
                SavedMerchant(
                  business: BusinessModel.fromSnapshot(business),
                  savedAt: _readSavedAt(snapshot.docs[index].data()),
                ),
          ];
        })
        .handleError((Object error) => throw toDiscoveryFailure(error));
  }

  @override
  Future<void> save({required String uid, required String businessId}) async {
    try {
      // The rules only allow creating this document, never overwriting it,
      // so saving a business twice is refused rather than resetting savedAt.
      await _savedMerchants(uid)
          .doc(businessId)
          .set({'savedAt': FieldValue.serverTimestamp()});
    } catch (error) {
      throw toDiscoveryFailure(error);
    }
  }

  @override
  Future<void> remove({required String uid, required String businessId}) async {
    try {
      await _savedMerchants(uid).doc(businessId).delete();
    } catch (error) {
      throw toDiscoveryFailure(error);
    }
  }

  /// savedAt is a server timestamp, so it is null in the local copy until
  /// the write reaches Firestore. "Now" keeps a just-saved shop on top.
  static DateTime _readSavedAt(Map<String, dynamic> data) {
    final savedAt = data['savedAt'];
    return savedAt is Timestamp ? savedAt.toDate() : DateTime.now();
  }
}
