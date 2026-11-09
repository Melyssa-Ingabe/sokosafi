import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  final int quantity;

  /// Null disables the button.
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: HugeIcons.strokeRoundedRemove01,
            label: 'Fewer',
            onPressed: onDecrease,
          ),
          SizedBox(
            width: AppSpacing.xl,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          _StepButton(
            icon: HugeIcons.strokeRoundedAdd01,
            label: 'More',
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final action = onPressed;
    return IconButton(
      tooltip: label,
      constraints: const BoxConstraints.tightFor(
        width: AppSpacing.minTapTarget,
        height: AppSpacing.minTapTarget,
      ),
      onPressed: action == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              action();
            },
      icon: HugeIcon(
        icon: icon,
        size: 20,
        color: action == null ? scheme.outline : scheme.primary,
      ),
    );
  }
}
