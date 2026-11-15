import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';
import 'package:sokosafi/features/listings/presentation/widgets/listing_category_icon.dart';

/// The listing photo, or its category icon while there is no photo, it is
/// still loading or it fails to load.
class ListingThumbnail extends StatelessWidget {
  const ListingThumbnail({
    super.key,
    required this.imageUrl,
    required this.category,
  });

  static const size = 48.0;

  final String imageUrl;
  final ListingCategory category;

  @override
  Widget build(BuildContext context) {
    final icon = Center(
      child: HugeIcon(icon: category.icon, color: AppColors.primary, size: 22),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: SizedBox.square(
        dimension: size,
        child: ColoredBox(
          color: AppColors.surfaceSubtle,
          child: imageUrl.isEmpty
              ? icon
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, frame, loadedSynchronously) {
                    if (loadedSynchronously) return child;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        icon,
                        AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: AnimationConstants.imageFade,
                          curve: AnimationConstants.imageFadeCurve,
                          child: child,
                        ),
                      ],
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => icon,
                ),
        ),
      ),
    );
  }
}
