/// Form validators shared by every feature. Each one returns an error
/// message, or null when the value is valid, so it works directly as a
/// TextFormField validator.
abstract final class Validators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  // Rwandan mobile numbers: 078/079 (MTN) and 072/073 (Airtel),
  // with an optional +250 or 250 prefix.
  static final RegExp _phonePattern = RegExp(r'^(\+?250|0)7[2389]\d{7}$');

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter your email address';
    if (!_emailPattern.hasMatch(trimmed)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter your name';
    if (trimmed.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? phone(String? value) {
    final digitsOnly = value?.replaceAll(RegExp(r'[\s-]'), '') ?? '';
    if (digitsOnly.isEmpty) return 'Enter your phone number';
    if (!_phonePattern.hasMatch(digitsOnly)) {
      return 'Enter a valid Rwandan phone number';
    }
    return null;
  }
}
