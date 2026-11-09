/// Rules for a listing form. Each method returns a message for the user, or
/// null when the value is valid, so text fields can use them directly and
/// the form cubit can re-check everything before saving.
abstract final class ListingValidator {
  static const int maxTitleLength = 60;
  static const int maxDescriptionLength = 300;
  static const int maxInstructionsLength = 120;
  static const int maxQuantity = 999;

  static String? title(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Tell customers what you are selling';
    if (trimmed.length < 3) return 'Name must be at least 3 characters';
    if (trimmed.length > maxTitleLength) {
      return 'Keep the name under $maxTitleLength characters';
    }
    return null;
  }

  static String? description(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Add a short description';
    if (trimmed.length > maxDescriptionLength) {
      return 'Keep the description under $maxDescriptionLength characters';
    }
    return null;
  }

  static String? originalPrice(String? value) {
    final price = parsePrice(value);
    if (price == null) return 'Enter the original price';
    if (price <= 0) return 'Price must be more than 0';
    return null;
  }

  /// The discount must be a real saving, so it has to be lower than the
  /// original price.
  static String? discountPrice(String? value, {required String? original}) {
    final discount = parsePrice(value);
    if (discount == null) return 'Enter the discount price';
    if (discount <= 0) return 'Price must be more than 0';
    final originalPrice = parsePrice(original);
    if (originalPrice != null && discount >= originalPrice) {
      return 'Discount price must be lower than the original';
    }
    return null;
  }

  static String? quantity(int quantity) {
    if (quantity < 1) return 'Quantity must be at least 1';
    if (quantity > maxQuantity) return 'Quantity must be $maxQuantity or less';
    return null;
  }

  static String? pickupBy(DateTime pickupBy, {required DateTime now}) {
    if (!pickupBy.isAfter(now)) return 'Pick-up time must be in the future';
    return null;
  }

  static String? madeAt(
    DateTime madeAt, {
    required DateTime pickupBy,
    required DateTime now,
  }) {
    if (madeAt.isAfter(now)) return 'Made-at time cannot be in the future';
    if (!madeAt.isBefore(pickupBy)) {
      return 'Made-at time must be before the pick-up time';
    }
    return null;
  }

  static String? instructions(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length > maxInstructionsLength) {
      return 'Keep instructions under $maxInstructionsLength characters';
    }
    return null;
  }

  /// Accepts "1,000" or "1000"; returns null when it is not a whole number.
  static int? parsePrice(String? value) {
    final digits = value?.replaceAll(RegExp(r'[\s,]'), '') ?? '';
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }
}
