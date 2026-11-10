import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/features/orders/presentation/cubit/my_orders_cubit.dart';

/// Two-option pill switch with a sliding highlight.
class OrdersTabSwitcher extends StatelessWidget {
  const OrdersTabSwitcher({
    super.key,
    required this.selected,
    required this.activeCount,
    required this.pastCount,
    required this.onSelected,
  });

  final OrdersTab selected;
  final int activeCount;
  final int pastCount;
  final ValueChanged<OrdersTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.minTapTarget),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: SizedBox(
          width: 240,
          height: AppSpacing.minTapTarget,
          child: Stack(
            children: [
              AnimatedAlign(
                duration: AnimationConstants.pageTransition,
                curve: AnimationConstants.pageCurve,
                alignment: selected == OrdersTab.active
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.minTapTarget,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _TabLabel(
                    label: 'Active ($activeCount)',
                    isSelected: selected == OrdersTab.active,
                    onTap: () => onSelected(OrdersTab.active),
                  ),
                  _TabLabel(
                    label: 'Past ($pastCount)',
                    isSelected: selected == OrdersTab.past,
                    onTap: () => onSelected(OrdersTab.past),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: AnimationConstants.listItem,
              curve: AnimationConstants.listCurve,
              style: theme.textTheme.labelMedium!.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
