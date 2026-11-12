/// A settings problem worded for the owner, so the UI never shows a raw
/// Firebase error.
class BusinessSettingsFailure implements Exception {
  const BusinessSettingsFailure(this.message);

  static const String genericMessage =
      'We could not save your settings. Please try again';

  final String message;

  @override
  String toString() => 'BusinessSettingsFailure: $message';
}
