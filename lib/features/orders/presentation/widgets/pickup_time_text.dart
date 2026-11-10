import 'package:flutter/material.dart';

/// "Pick up today by 6:30 PM", or the date when it is not today.
class PickupTimeText extends StatelessWidget {
  const PickupTimeText({super.key, required this.pickupBy, this.style});

  final DateTime pickupBy;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(pickupBy),
    );
    final now = DateTime.now();
    final isToday =
        pickupBy.year == now.year &&
        pickupBy.month == now.month &&
        pickupBy.day == now.day;
    final day = isToday ? 'today' : localizations.formatShortMonthDay(pickupBy);
    return Text('Pick up $day by $time', style: style);
  }
}
