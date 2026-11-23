import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';

/// A big number over a short label, like the dashboard's "Today" figures.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          children: [
            // Shrinks long numbers on small phones instead of overflowing.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
