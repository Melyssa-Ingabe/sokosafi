import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

/// "All" plus one chip per category, scrolling sideways like the filter
/// chips in Figma. The selected chip is filled green.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// Null means "All".
  final ListingCategory? selected;
  final ValueChanged<ListingCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: [
          _CategoryChip(
            label: 'All',
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final category in ListingCategory.values) ...[
            const SizedBox(width: AppSpacing.sm),
            _CategoryChip(
              label: category.label,
              isSelected: selected == category,
              onTap: () => onSelected(category),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : Theme.of(context).colorScheme.outlineVariant,
      ),
      shape: const StadiumBorder(),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: isSelected
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface,
      ),
      // Keeps every chip a full 48px tall to tap.
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
