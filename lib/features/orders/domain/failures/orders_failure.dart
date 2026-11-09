/// A problem worded for the customer, so the UI never shows a raw
/// Firebase error.
class OrdersFailure implements Exception {
  const OrdersFailure(this.message);

  static const String genericMessage = 'Something went wrong. Please try again';

  final String message;

  @override
  String toString() => 'OrdersFailure: $message';
}
