import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';

/// Pill switch with a highlight that slides to the selected option.
/// Fills the available width unless [width] is given.
class PillSegmentedControl extends StatelessWidget {
  const PillSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.width,
  }) : assert(labels.length >= 2);

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Alignment x runs from -1 (first option) to 1 (last option).
    final highlightX = -1.0 + 2.0 * selectedIndex / (labels.length - 1);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLowest,
        shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: SizedBox(
          width: width,
          height: AppSpacing.minTapTarget,
          child: Stack(
            children: [
              AnimatedAlign(
                duration: AnimationConstants.pageTransition,
                curve: AnimationConstants.pageCurve,
                alignment: Alignment(highlightX, 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / labels.length,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: scheme.primary,
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final (index, label) in labels.indexed)
                    _SegmentLabel(
                      label: label,
                      isSelected: index == selectedIndex,
                      onTap: () => onSelected(index),
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

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({
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
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ),
    );
  }
}
