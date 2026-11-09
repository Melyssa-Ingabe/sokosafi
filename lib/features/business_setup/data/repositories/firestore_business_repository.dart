import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/auth/domain/entities/user_role.dart';
import 'package:sokosafi/features/business_setup/data/models/business_model.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_setup_input.dart';
import 'package:sokosafi/features/business_setup/domain/failures/business_failure.dart';
import 'package:sokosafi/features/business_setup/domain/repositories/business_repository.dart';

class FirestoreBusinessRepository implements BusinessRepository {
  FirestoreBusinessRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _businesses =>
      _firestore.collection('businesses');

  @override
  Stream<Business?> watchOwnedBusiness(String ownerId) {
    return _businesses
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .snapshots()
        .map<Business?>(
          (query) => query.docs.isEmpty
              ? null
              : BusinessModel.fromSnapshot(query.docs.first),
        )
        .handleError((Object error) => throw _toFailure(error));
  }

  @override
  Future<String> createBusiness({
    required String ownerId,
    required BusinessSetupInput input,
  }) async {
    try {
      // One user owns at most one business, so a second setup is refused.
      final existing = await _businesses
          .where('ownerId', isEqualTo: ownerId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        throw const BusinessFailure('You already have a business set up');
      }

      // The business and the owner's new role are written in one batch, so
      // the app never sees a business user without a business, or the
      // other way round.
      final businessDocument = _businesses.doc();
      final batch = _firestore.batch()
        ..set(
          businessDocument,
          BusinessModel.createMap(ownerId: ownerId, input: input),
        )
        ..update(_firestore.collection('users').doc(ownerId), {
          'role': UserRole.business.name,
        });
      await batch.commit();
      return businessDocument.id;
    } catch (error) {
      throw _toFailure(error);
    }
  }

  BusinessFailure _toFailure(Object error) {
    if (error is BusinessFailure) return error;
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return const BusinessFailure(
            'You do not have permission to set up this business',
          );
        case 'not-found':
          return const BusinessFailure(
            'We could not find your account. Please sign in again',
          );
        case 'unavailable':
        case 'deadline-exceeded':
          return const BusinessFailure(
            'You seem to be offline. Check your connection and try again',
          );
      }
    }
    return const BusinessFailure(BusinessFailure.genericMessage);
  }
}
