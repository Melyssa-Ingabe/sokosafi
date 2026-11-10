import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sokosafi/features/auth/domain/entities/app_user.dart';
import 'package:sokosafi/features/auth/domain/entities/user_role.dart';

/// Maps Firebase Auth and the users/{uid} document to an [AppUser].
class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.phone,
    required super.role,
    required super.photoUrl,
    required super.foodPreferences,
    required super.isEmailVerified,
  });

  /// The profile document may be missing or unreadable, so every field falls
  /// back to what Firebase Auth knows.
  factory UserModel.fromFirebase({
    required User firebaseUser,
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
  }) {
    final data = snapshot?.data() ?? const <String, dynamic>{};
    final storedPreferences = data['foodPreferences'] as List<dynamic>?;
    return UserModel(
      uid: firebaseUser.uid,
      email: _firstNonEmpty(firebaseUser.email, data['email'] as String?),
      name: _firstNonEmpty(data['name'] as String?, firebaseUser.displayName),
      phone: _firstNonEmpty(data['phone'] as String?, firebaseUser.phoneNumber),
      role: UserRole.fromName(data['role'] as String?),
      photoUrl: _firstNonEmpty(
        data['photoUrl'] as String?,
        firebaseUser.photoURL,
      ),
      foodPreferences:
          storedPreferences?.whereType<String>().toList() ?? const <String>[],
      isEmailVerified: firebaseUser.emailVerified,
    );
  }

  /// Fields of a new users document. They match the ERD exactly; the uid is
  /// the document id, not a field.
  static Map<String, dynamic> newProfileMap({
    required String name,
    required String email,
    required String phone,
    String photoUrl = '',
  }) {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': UserRole.customer.name,
      'foodPreferences': <String>[],
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static String _firstNonEmpty(String? first, String? second) {
    if (first != null && first.isNotEmpty) return first;
    return second ?? '';
  }
}
