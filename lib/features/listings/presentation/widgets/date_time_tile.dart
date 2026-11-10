import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/app_badge.dart';

/// A labelled, tappable row showing a date and time, such as the pickup
/// deadline. Tapping opens the date and time pickers.
class DateTimeTile extends StatelessWidget {
  const DateTimeTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.badge,
    this.helperText,
    this.errorText,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  /// Short chip on the right, for example "In 2h".
  final String? badge;
  final String? helperText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurfaceVariant;
    final error = errorText;
    final helper = helperText;
    final chip = badge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: mutedColor),
        ),
        const SizedBox(height: AppSpacing.xs),
        Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            side: BorderSide(
              color: error != null ? AppColors.error : AppColors.borderSubtle,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedClock01,
                    color: mutedColor,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(value, style: theme.textTheme.bodyLarge),
                  ),
                  if (chip != null) ...[
                    AppBadge(
                      label: chip,
                      backgroundColor: AppColors.surfaceSubtle,
                      foregroundColor: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  // Keeps the row at least 48px tall for an easy tap.
                  SizedBox(
                    height: AppSpacing.minTapTarget,
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowDown01,
                      color: mutedColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (error != null || helper != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            error ?? helper!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: error != null ? theme.colorScheme.error : mutedColor,
            ),
          ),
        ],
      ],
    );
  }
}
