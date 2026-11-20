/// A problem worded for the customer, so the UI never shows a raw
/// Firebase error.
class DiscoveryFailure implements Exception {
  const DiscoveryFailure(this.message);

  static const String genericMessage = 'Something went wrong. Please try again';

  final String message;

  @override
  String toString() => 'DiscoveryFailure: $message';
}
