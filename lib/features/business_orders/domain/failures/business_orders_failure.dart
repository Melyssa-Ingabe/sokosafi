/// Firebase error.
class BusinessOrdersFailure implements Exception {
  const BusinessOrdersFailure(this.message);

  static const String genericMessage = 'Something went wrong. Please try again';

  final String message;

  @override
  String toString() => 'BusinessOrdersFailure: $message';
}
