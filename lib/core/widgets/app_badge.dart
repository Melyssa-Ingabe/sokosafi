import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';

/// Pill-shaped label, used for discounts and status. Defaults to the lime
/// badge. [showDot] adds the small leading dot used for live counts such as
/// "5 reserved".
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.lime,
    this.foregroundColor = AppColors.onLime,
    this.showDot = false,
    this.dotColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool showDot;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              SizedBox.square(
                dimension: 6,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: dotColor ?? AppColors.primary,
                    shape: const CircleBorder(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
