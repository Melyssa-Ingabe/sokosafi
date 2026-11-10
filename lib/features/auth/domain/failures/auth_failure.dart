/// A problem the user can read. The data layer words it politely, so the UI
/// never shows a raw Firebase error.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  static const String genericMessage = 'Something went wrong. Please try again';

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}
