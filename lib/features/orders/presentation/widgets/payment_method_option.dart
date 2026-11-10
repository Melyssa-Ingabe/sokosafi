import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';

/// A selectable payment method. The selected one reveals [details] below
/// its title, so only the relevant input is on screen.
class PaymentMethodOption extends StatelessWidget {
  const PaymentMethodOption({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onSelected,
    this.details,
  });

  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onSelected;
  final Widget? details;

  String get _subtitle => switch (method) {
    PaymentMethod.mtnMomo => 'Approve the MoMo prompt on your phone',
    PaymentMethod.airtelMoney => 'Approve the Airtel Money prompt',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TapScale(
      child: AnimatedContainer(
        duration: AnimationConstants.listItem,
        curve: AnimationConstants.listCurve,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            onTap: () {
              if (isSelected) return;
              HapticFeedback.selectionClick();
              onSelected();
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AnimatedSize(
                duration: AnimationConstants.pageTransition,
                curve: AnimationConstants.pageCurve,
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.label,
                                style: theme.textTheme.labelMedium,
                              ),
                              Text(
                                _subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _SelectionDot(isSelected: isSelected),
                      ],
                    ),
                    if (isSelected && details != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      details!,
                    ],
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

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AnimationConstants.listItem,
      curve: AnimationConstants.listCurve,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? scheme.primary : scheme.outline,
          width: isSelected ? 6 : 1.5,
        ),
      ),
    );
  }
}
