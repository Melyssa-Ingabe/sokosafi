import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';
import 'package:sokosafi/features/listings/presentation/widgets/listing_category_icon.dart';

/// The four category tiles. The selected one is filled green.
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ListingCategory selected;
  final ValueChanged<ListingCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        for (final category in ListingCategory.values) ...[
          if (category != ListingCategory.values.first)
            const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Semantics(
              selected: category == selected,
              button: true,
              child: TapScale(
                child: AnimatedContainer(
                  duration: AnimationConstants.listItem,
                  curve: AnimationConstants.pageCurve,
                  decoration: BoxDecoration(
                    color: category == selected
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                    border: Border.all(
                      color: category == selected
                          ? AppColors.primary
                          : AppColors.borderSubtle,
                    ),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () => onSelected(category),
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        child: Column(
                          children: [
                            HugeIcon(
                              icon: category.icon,
                              size: 24,
                              color: category == selected
                                  ? AppColors.surface
                                  : AppColors.primary,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                category.label,
                                style: textTheme.labelMedium?.copyWith(
                                  color: category == selected
                                      ? AppColors.surface
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
