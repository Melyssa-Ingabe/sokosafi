import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/app_badge.dart';

/// Read-only row showing the neighborhood detected from the pin.
class NeighborhoodTile extends StatelessWidget {
  const NeighborhoodTile({super.key, required this.neighborhood});

  final String neighborhood;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDetected = neighborhood.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedNavigation03,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                isDetected ? neighborhood : 'Place the pin to detect your area',
                style: isDetected
                    ? theme.textTheme.bodyLarge
                    : theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
            if (isDetected) ...[
              const SizedBox(width: AppSpacing.sm),
              const AppBadge(
                label: 'Detected',
                backgroundColor: AppColors.surfaceSubtle,
                foregroundColor: AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
