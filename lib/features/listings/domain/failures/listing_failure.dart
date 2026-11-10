/// A listing problem worded for the user, so screens never show a raw
/// Firebase error.
class ListingFailure implements Exception {
  const ListingFailure(this.message);

  static const String genericMessage =
      'Something went wrong with your listing. Please try again';

  final String message;

  @override
  String toString() => 'ListingFailure: $message';
}
