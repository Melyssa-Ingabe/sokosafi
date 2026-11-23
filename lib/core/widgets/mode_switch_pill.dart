import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';

/// The pill naming the side of the app the user is on ("Selling" or
/// "Buying"). Tapping it switches to the other side.
class ModeSwitchPill extends StatelessWidget {
  const ModeSwitchPill({
    super.key,
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TapScale(
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: scheme.surfaceContainerHighest,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.minTapTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowDataTransferHorizontal,
                      size: 18,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
