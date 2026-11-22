/// Hands a phone number to the phone app. Kept behind an interface so
/// widgets can be tested without dialling.
abstract interface class PhoneLauncher {
  /// Returns false when this device cannot place calls.
  Future<bool> call(String phone);
}
