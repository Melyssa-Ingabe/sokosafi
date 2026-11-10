import 'package:flutter/material.dart';

/// Asks for a day, then a time. Returns null if either picker is cancelled.
Future<DateTime?> pickDateTime(
  BuildContext context, {
  required DateTime initial,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final day = await showDatePicker(
    context: context,
    initialDate: initial.isBefore(firstDate)
        ? firstDate
        : (initial.isAfter(lastDate) ? lastDate : initial),
    firstDate: firstDate,
    lastDate: lastDate,
  );
  if (day == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
  );
  if (time == null) return null;
  return DateTime(day.year, day.month, day.day, time.hour, time.minute);
}
