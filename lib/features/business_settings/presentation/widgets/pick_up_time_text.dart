import 'package:flutter/material.dart';

/// Converts between the "HH:mm" text stored on businesses and the
/// TimeOfDay used by the time picker.
abstract final class PickupTimeText {
  static TimeOfDay toTimeOfDay(String text) {
    final parts = text.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) : null;
    return TimeOfDay(hour: hour ?? 8, minute: minute ?? 0);
  }

  static String fromTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
