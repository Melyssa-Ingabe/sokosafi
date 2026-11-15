import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/features/business_orders/presentation/bloc/business_orders_cubit.dart';

/// Three-option pill switch with a sliding highlight and a count per tab.
class BusinessOrdersTabBar extends StatelessWidget {
  const BusinessOrdersTabBar({
    super.key,
    required this.selected,
    required this.countFor,
    required this.onSelected,
  });

  final BusinessOrdersTab selected;
  final int Function(BusinessOrdersTab tab) countFor;
  final ValueChanged<BusinessOrdersTab> onSelected;

  String _labelFor(BusinessOrdersTab tab) => switch (tab) {
    BusinessOrdersTab.incoming => 'Incoming',
    BusinessOrdersTab.completed => 'Completed',
    BusinessOrdersTab.cancelled => 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const tabs = BusinessOrdersTab.values;
    // Alignment x of -1, 0 and 1 puts the highlight under the first,
    // middle and last tab.
    final highlightX = -1.0 + 2.0 * selected.index / (tabs.length - 1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.minTapTarget),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: SizedBox(
            height: AppSpacing.minTapTarget,
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: AnimationConstants.pageTransition,
                  curve: AnimationConstants.pageCurve,
                  alignment: Alignment(highlightX, 0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / tabs.length,
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
                    for (final tab in tabs)
                      _TabLabel(
                        label: '${_labelFor(tab)} (${countFor(tab)})',
                        isSelected: tab == selected,
                        onTap: () => onSelected(tab),
                      ),
                  ],
                ),
              ],
            ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              // Shrinks the label on very narrow phones instead of
              // overflowing.
              child: FittedBox(
                fit: BoxFit.scaleDown,
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
        ),
      ),
    );
  }
}
