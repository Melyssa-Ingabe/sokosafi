import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sokosafi/features/auth/data/mappers/auth_error_mapper.dart';
import 'package:sokosafi/features/auth/data/models/user_model.dart';
import 'package:sokosafi/features/auth/domain/entities/app_user.dart';
import 'package:sokosafi/features/auth/domain/failures/auth_failure.dart';
import 'package:sokosafi/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  Future<void>? _googleInitialization;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Stream<AppUser?> watchUser() {
    StreamSubscription<User?>? authSubscription;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    profileSubscription;
    final controller = StreamController<AppUser?>();

    // Follows the signed-in user and, for each one, their profile document.
    // The profile listener is replaced whenever the auth user changes, so a
    // role update in Firestore reaches the app immediately.
    controller.onListen = () {
      authSubscription = _firebaseAuth.userChanges().listen((firebaseUser) {
        profileSubscription?.cancel();
        if (firebaseUser == null) {
          controller.add(null);
          return;
        }
        profileSubscription = _users
            .doc(firebaseUser.uid)
            .snapshots()
            .listen(
              (snapshot) => controller.add(
                UserModel.fromFirebase(
                  firebaseUser: _firebaseAuth.currentUser ?? firebaseUser,
                  snapshot: snapshot,
                ),
              ),
              onError: (Object _) {
                // Signing out revokes access to the old profile and raises an
                // error just before the null user event; ignore that one.
                if (_firebaseAuth.currentUser == null) return;
                // An unreadable profile must not log the user out.
                controller.add(
                  UserModel.fromFirebase(firebaseUser: firebaseUser),
                );
              },
            );
      }, onError: controller.addError);
    };
    controller.onCancel = () async {
      await profileSubscription?.cancel();
      await authSubscription?.cancel();
    };
    return controller.stream;
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    });
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    return _guard(() async {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthFailure(AuthFailure.genericMessage);
      }
      await firebaseUser.updateDisplayName(name.trim());
      await _users
          .doc(firebaseUser.uid)
          .set(
            UserModel.newProfileMap(
              name: name.trim(),
              email: email.trim(),
              phone: phone.trim(),
            ),
          );
      await firebaseUser.sendEmailVerification();
    });
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final account = await _googleSignIn.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) await _createProfileIfMissing(firebaseUser);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return;
      throw AuthFailure(authErrorMessage('google-sign-in-failed'));
    } on FirebaseException catch (error) {
      throw AuthFailure(authErrorMessage(error.code));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _guard(
      () => _firebaseAuth.sendPasswordResetEmail(email: email.trim()),
    );
  }

  @override
  Future<void> resendVerificationEmail() {
    return _guard(() async {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    });
  }

  @override
  Future<bool> reloadUser() {
    return _guard(() async {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return false;
      await firebaseUser.reload();
      // Forcing a new token makes the user stream emit the verified state.
      await _firebaseAuth.currentUser?.getIdToken(true);
      return _firebaseAuth.currentUser?.emailVerified ?? false;
    });
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();
    } catch (_) {
      // Firebase sign-out already succeeded; leftover Google state is harmless.
    }
  }

  /// google_sign_in 7 requires initialize() exactly once before any other call.
  Future<void> _ensureGoogleInitialized() {
    return _googleInitialization ??= _googleSignIn.initialize().catchError((
      Object error,
    ) {
      _googleInitialization = null;
      throw error;
    });
  }

  /// Google users skip registration, so their profile is created here. Their
  /// phone number is unknown and stays empty until they add it.
  Future<void> _createProfileIfMissing(User firebaseUser) async {
    final document = _users.doc(firebaseUser.uid);
    final snapshot = await document.get();
    if (snapshot.exists) return;
    await document.set(
      UserModel.newProfileMap(
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber ?? '',
        photoUrl: firebaseUser.photoURL ?? '',
      ),
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (error) {
      throw AuthFailure(authErrorMessage(error.code));
    }
  }
}
