import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';

/// One button in a [FloatingNavBar].
class FloatingNavItem {
  const FloatingNavItem({
    required this.label,
    required this.icon,
    this.showsLabel = false,
  });

  final String label;
  final List<List<dynamic>> icon;

  /// Drawn as a wider pill with its label, like "search" or "+ List".
  final bool showsLabel;
}

/// The bottom navigation from Figma: a row of floating white circles with
/// one wider pill. Used by both the customer and the business side.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<FloatingNavItem> items;

  /// Null when the open screen has no button of its own.
  final int? selectedIndex;
  final ValueChanged<int> onTap;

  static const double _gap = AppSpacing.md;
  static const double _pillWidth = 108;
  static const double _circle = AppSpacing.minTapTarget + AppSpacing.sm;

  double get _fullWidth {
    final pills = items.where((item) => item.showsLabel).length;
    return _circle * (items.length - pills) +
        _pillWidth * pills +
        _gap * (items.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // On narrow phones a pill becomes a circle like the others, so the
        // bar never overflows.
        final roomForPill = constraints.maxWidth >= _fullWidth;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final (index, item) in items.indexed)
              _NavButton(
                item: item,
                showLabel: item.showsLabel && roomForPill,
                isSelected: index == selectedIndex,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(index);
                },
              ),
          ],
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.showLabel,
    required this.isSelected,
    required this.onTap,
  });

  final FloatingNavItem item;
  final bool showLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isSelected ? scheme.primary : scheme.onSurface;
    final icon = HugeIcon(icon: item.icon, size: 24, color: color);
    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      excludeSemantics: true,
      child: Tooltip(
        message: item.label,
        child: TapScale(
          child: Material(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.14)
                : scheme.surfaceContainerLowest,
            shape: const StadiumBorder(),
            elevation: 2,
            shadowColor: scheme.shadow.withValues(alpha: 0.2),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: SizedBox(
                  height: FloatingNavBar._circle,
                  width: showLabel
                      ? FloatingNavBar._pillWidth
                      : FloatingNavBar._circle,
                  child: showLabel
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            icon,
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              item.label,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: color),
                            ),
                          ],
                        )
                      : Center(child: icon),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
