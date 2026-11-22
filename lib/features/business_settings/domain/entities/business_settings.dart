import 'package:equatable/equatable.dart';

/// The fields on a businesses document that the owner changes from
/// Business Settings.
class BusinessSettings extends Equatable {
  const BusinessSettings({
    required this.acceptingOrders,
    required this.autoClose,
    required this.pickupStart,
    required this.pickupEnd,
    required this.landmark,
    this.phone = '',
  });

  static const int maxLandmarkLength = 120;
  static const int maxPhoneLength = 20;

  final bool acceptingOrders;

  /// Pause a listing automatically once its last portion is reserved.
  final bool autoClose;

  /// Daily pickup window as 24-hour "HH:mm" text, for example "17:30".
  final String pickupStart;
  final String pickupEnd;

  /// Helps customers find the pickup point. Empty when not set.
  final String landmark;

  /// The number customers call about an order. Empty when not set.
  final String phone;

  /// Empty clears the number. Otherwise 9 to 15 digits, with optional
  /// spaces, dashes and a leading +.
  static bool isValidPhone(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return true;
    if (!RegExp(r'^\+?[0-9 -]+$').hasMatch(trimmed)) return false;
    final digits = trimmed.replaceAll(RegExp(r'\D'), '').length;
    return digits >= 9 && digits <= 15;
  }

  /// Zero-padded "HH:mm" text sorts the same way as the times themselves.
  static bool isValidPickupWindow(String start, String end) =>
      start.compareTo(end) < 0;

  @override
  List<Object?> get props => [
    acceptingOrders,
    autoClose,
    pickupStart,
    pickupEnd,
    landmark,
    phone,
  ];
}
