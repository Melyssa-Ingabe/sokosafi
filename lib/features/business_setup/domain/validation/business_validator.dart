import 'package:sokosafi/features/business_setup/domain/entities/business_type.dart';

/// Rules for the setup steps. Each returns a message for the user, or null
/// when the value is valid.
abstract final class BusinessValidator {
  static const int maxNameLength = 60;
  static const int maxAddressLength = 120;

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter your business name';
    if (trimmed.length < 2) return 'Name must be at least 2 characters';
    if (trimmed.length > maxNameLength) {
      return 'Keep the name under $maxNameLength characters';
    }
    return null;
  }

  static String? type(BusinessType? type) {
    return type == null ? 'Choose what kind of business you run' : null;
  }

  static String? address(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter your address or a landmark';
    if (trimmed.length > maxAddressLength) {
      return 'Keep the address under $maxAddressLength characters';
    }
    return null;
  }

  static String? location({double? latitude, double? longitude}) {
    if (latitude == null || longitude == null) {
      return 'Place the pin on your business';
    }
    return null;
  }

  /// The ERD has a single address field, so the detected neighborhood is
  /// added to it unless the owner already typed it.
  static String fullAddress({
    required String address,
    required String neighborhood,
  }) {
    final trimmedAddress = address.trim();
    final trimmedNeighborhood = neighborhood.trim();
    if (trimmedNeighborhood.isEmpty) return trimmedAddress;
    final firstPart = trimmedNeighborhood.split(',').first.trim().toLowerCase();
    if (trimmedAddress.toLowerCase().contains(firstPart)) return trimmedAddress;
    return '$trimmedAddress, $trimmedNeighborhood';
  }
}
