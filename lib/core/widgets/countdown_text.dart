import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/utils/formatters.dart';

/// Time left until a deadline, refreshed every 30 seconds. Turns
/// [urgentColor] when less than 30 minutes remain. With [showIcon] a clock
/// sits in front, which becomes an alarm clock when urgent.
class CountdownText extends StatelessWidget {
  const CountdownText({
    super.key,
    required this.deadline,
    this.style,
    this.showIcon = false,
    this.urgentColor = AppColors.warning,
  });

  final DateTime deadline;
  final TextStyle? style;
  final bool showIcon;
  final Color urgentColor;

  static const Duration urgentThreshold = Duration(minutes: 30);

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
        final isUrgent = remaining < urgentThreshold;
        final text = Text(
          Formatters.timeLeft(remaining),
          style: style?.copyWith(color: isUrgent ? urgentColor : null),
        );
        if (!showIcon) return text;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: isUrgent
                  ? HugeIcons.strokeRoundedAlarmClock
                  : HugeIcons.strokeRoundedClock01,
              size: 16,
              color: isUrgent
                  ? urgentColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(child: text),
          ],
        );
      },
    );
  }
}
