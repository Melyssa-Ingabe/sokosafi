/// A review problem worded for the user, so screens never show a raw
/// Firebase error.
class ReviewFailure implements Exception {
  const ReviewFailure(this.message);

  static const String genericMessage = 'Something went wrong. Please try again';

  final String message;

  @override
  String toString() => 'ReviewFailure: $message';
}
