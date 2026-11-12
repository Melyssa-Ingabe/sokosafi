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
  });

  static const int maxLandmarkLength = 120;

  final bool acceptingOrders;

  /// Pause a listing automatically once its last portion is reserved.
  final bool autoClose;

  /// Daily pickup window as 24-hour "HH:mm" text, for example "17:30".
  final String pickupStart;
  final String pickupEnd;

  /// Helps customers find the pickup point. Empty when not set.
  final String landmark;

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
  ];
}
