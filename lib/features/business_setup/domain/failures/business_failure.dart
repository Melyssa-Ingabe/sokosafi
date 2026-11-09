/// A business setup problem worded for the user, so screens never show a raw
/// Firebase or plugin error.
class BusinessFailure implements Exception {
  const BusinessFailure(this.message);

  static const String genericMessage =
      'Something went wrong setting up your business. Please try again';

  final String message;

  @override
  String toString() => 'BusinessFailure: $message';
}
