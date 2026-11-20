import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';
import 'package:sokosafi/features/listings/presentation/widgets/listing_category_icon.dart';

/// One category on the Food Preferences grid. Selected tiles turn light
/// green with a dot in the corner, as in Figma.
class PreferenceTile extends StatelessWidget {
  const PreferenceTile({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final ListingCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    // The green text on the light green tile is the brand primary rather
    // than Figma's accent, which is too light to read at this size.
    final foreground = isSelected ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? AppColors.brandSubtle : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: AppColors.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(icon: category.icon, size: 24, color: foreground),
                    const SizedBox(height: 10),
                    Text(
                      category.label,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Positioned(
                  top: 7,
                  right: 7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(dimension: 8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
