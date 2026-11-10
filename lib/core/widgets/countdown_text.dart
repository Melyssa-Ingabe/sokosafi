import 'package:flutter/material.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/utils/formatters.dart';

/// Time left until a deadline, refreshed every 30 seconds.
/// Turns warning-colored when less than 30 minutes remain.
class CountdownText extends StatelessWidget {
  const CountdownText({super.key, required this.deadline, this.style});

  final DateTime deadline;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 30),
        (_) => DateTime.now(),
      ),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final remaining = deadline.difference(snapshot.data ?? DateTime.now());
        final isUrgent = remaining < const Duration(minutes: 30);
        return Text(
          Formatters.timeLeft(remaining),
          style: style?.copyWith(color: isUrgent ? AppColors.warning : null),
        );
      },
    );
  }
}
