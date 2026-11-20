import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/utils/date_formatters.dart';
import 'package:sokosafi/core/widgets/countdown_text.dart';

/// When the food was made and the latest time to pick it up.
class PickupTimesCard extends StatelessWidget {
  const PickupTimesCard({
    super.key,
    required this.madeAt,
    required this.pickupBy,
    required this.now,
  });

  final DateTime madeAt;
  final DateTime pickupBy;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _TimeRow(
              label: 'Made',
              value: DateFormatters.dayAndTime(madeAt, now: now),
            ),
            const SizedBox(height: AppSpacing.sm),
            _TimeRow(
              label: 'Pick up by',
              value: DateFormatters.dayAndTime(pickupBy, now: now),
              trailing: CountdownText(
                deadline: pickupBy,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        HugeIcon(
          icon: HugeIcons.strokeRoundedClock01,
          size: 18,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label  ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
            style: theme.textTheme.bodyMedium,
          ),
        ),
        ?trailing,
      ],
    );
  }
}
