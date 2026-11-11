import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/features/reviews/domain/entities/review_tag.dart';

class ReviewTagChips extends StatelessWidget {
  const ReviewTagChips({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<ReviewTag> selected;
  final ValueChanged<ReviewTag> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final tag in ReviewTag.values)
          FilterChip(
            label: Text(tag.label),
            selected: selected.contains(tag),
            onSelected: (_) => onToggle(tag),
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
      ],
    );
  }
}
