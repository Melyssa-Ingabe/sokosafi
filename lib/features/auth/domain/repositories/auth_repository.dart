import 'package:sokosafi/features/auth/domain/entities/app_user.dart';

/// What the app needs from authentication. Firebase stays behind this
/// interface, so the BLoC can be tested with a mock.
abstract interface class AuthRepository {
  /// Emits the signed-in user with profile data, or null when signed out.
  Stream<AppUser?> watchUser();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  /// Returns normally, without signing in, when the user closes the picker.
  Future<void> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<void> resendVerificationEmail();

  /// Refreshes the account and returns whether the email is now verified.
  Future<bool> reloadUser();

  Future<void> signOut();
}
