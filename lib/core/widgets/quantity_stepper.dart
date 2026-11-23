import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';

/// The outlined pill from Figma: a grey minus circle, the count, and a
/// filled green plus circle. Each circle sits in a full 48px tap target.
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
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLowest,
        shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: HugeIcons.strokeRoundedRemove01,
            label: 'Fewer',
            isFilled: false,
            onPressed: onDecrease,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: AppSpacing.xl),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Text(
                '$quantity',
                key: ValueKey(quantity),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          _StepButton(
            icon: HugeIcons.strokeRoundedAdd01,
            label: 'More',
            isFilled: true,
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
    required this.isFilled,
    required this.onPressed,
  });

  final List<List<dynamic>> icon;
  final String label;
  final bool isFilled;
  final VoidCallback? onPressed;

  static const double _circle = 40;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final action = onPressed;
    final isEnabled = action != null;
    final background = isFilled && isEnabled
        ? scheme.primary
        : scheme.surfaceContainerHighest;
    final foreground = !isEnabled
        ? scheme.outline
        : isFilled
        ? scheme.onPrimary
        : scheme.onSurface;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      excludeSemantics: true,
      child: TapScale(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isEnabled
              ? () {
                  HapticFeedback.selectionClick();
                  action();
                }
              : null,
          child: SizedBox.square(
            dimension: AppSpacing.minTapTarget,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: _circle,
                height: _circle,
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(icon: icon, size: 18, color: foreground),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
