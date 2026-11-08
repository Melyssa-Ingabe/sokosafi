import 'package:sokosafi/features/auth/domain/failures/auth_failure.dart';

/// Turns a Firebase error code into a message a user can act on.
String authErrorMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Enter a valid email address';
    case 'user-disabled':
      return 'This account has been disabled';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return 'Wrong email or password, try again';
    case 'email-already-in-use':
      return 'This email is already registered';
    case 'weak-password':
      return 'Choose a stronger password of at least 8 characters';
    case 'too-many-requests':
      return 'Too many attempts. Wait a moment and try again';
    case 'network-request-failed':
      return 'No internet connection. Check your network and try again';
    case 'operation-not-allowed':
      return 'This sign-in method is not available right now';
    case 'account-exists-with-different-credential':
      return 'An account already exists with this email using another sign-in method';
    case 'google-sign-in-failed':
      return 'Google sign-in did not work. Try again';
    case 'permission-denied':
      return 'You do not have permission to do that';
    default:
      return AuthFailure.genericMessage;
  }
}
