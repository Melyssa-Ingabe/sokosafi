import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokosafi/features/profile/domain/failures/profile_failure.dart';
import 'package:sokosafi/features/profile/domain/repositories/profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    try {
      // The auth stream listens to this document, so the new name shows up
      // everywhere without any extra refresh.
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'name': name.trim(), 'phone': phone.trim()})
          .timeout(const Duration(seconds: 20));
    } on FirebaseException catch (error) {
      throw ProfileFailure(switch (error.code) {
        'unavailable' => 'You seem to be offline. Try again when connected',
        'permission-denied' => 'You cannot edit this profile',
        _ => 'We could not save your profile. Please try again',
      });
    } on TimeoutException {
      throw const ProfileFailure(
        'This is taking too long. Check your connection and try again',
      );
    }
  }
}
