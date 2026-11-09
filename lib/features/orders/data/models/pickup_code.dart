import 'dart:math';

/// Codes like SKS-4A7F2B. Letters that look like digits (I, O) and the
/// digits 0 and 1 are left out so the code is easy to read aloud.
abstract final class PickupCode {
  static const String _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static final RegExp pattern = RegExp(r'^SKS-[A-HJ-NP-Z2-9]{6}$');

  static String generate([Random? random]) {
    final source = random ?? Random.secure();
    final characters = List.generate(
      6,
      (_) => _alphabet[source.nextInt(_alphabet.length)],
    );
    return 'SKS-${characters.join()}';
  }
}
