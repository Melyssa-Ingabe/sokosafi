import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/setup_progress_bar.dart';

/// "X  1 of 3" row with the progress bar underneath. Shows a close button on
/// the first step and a back arrow after that.
class SetupHeader extends StatelessWidget {
  const SetupHeader({
    super.key,
    required this.stepNumber,
    required this.stepCount,
    required this.onLeading,
  });

  final int stepNumber;
  final int stepCount;
  final VoidCallback onLeading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFirstStep = stepNumber == 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.pagePadding,
        0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onLeading,
                tooltip: isFirstStep ? 'Close' : 'Back',
                icon: HugeIcon(
                  icon: isFirstStep
                      ? HugeIcons.strokeRoundedCancel01
                      : HugeIcons.strokeRoundedArrowLeft01,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Expanded(
                child: Text(
                  '$stepNumber of $stepCount',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              // Balances the leading button so the step label stays centered.
              const SizedBox(width: AppSpacing.minTapTarget),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: SetupProgressBar(progress: stepNumber / stepCount),
          ),
        ],
      ),
    );
  }
}
