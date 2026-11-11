import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/features/business_analytics/domain/entities/analytics_range.dart';

/// Today / Week / Month / All time chips. Scrolls sideways on narrow
/// phones instead of overflowing.
class AnalyticsRangeSelector extends StatelessWidget {
  const AnalyticsRangeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AnalyticsRange selected;
  final ValueChanged<AnalyticsRange> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: [
          for (final range in AnalyticsRange.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(range.label),
                selected: range == selected,
                onSelected: (_) => onSelected(range),
                materialTapTargetSize: MaterialTapTargetSize.padded,
              ),
            ),
        ],
      ),
    );
  }
}
