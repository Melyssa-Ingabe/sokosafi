import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';

/// The listing photo as a rounded card at the top of the detail sheet,
/// with an optional round button in its top-right corner.
class ProductPhotoHeader extends StatelessWidget {
  const ProductPhotoHeader({super.key, required this.imageUrl, this.action});

  final String imageUrl;

  /// Shown in the top-right corner, where Figma has its round button.
  final Widget? action;

  static const double height = 268;
  static const double _radius = 24;

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(
      color: AppColors.surfaceSubtle,
      child: Center(
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedImage01,
          color: AppColors.textSecondary,
          size: 40,
        ),
      ),
    );

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isEmpty)
              placeholder
            else
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronous) =>
                    AnimatedOpacity(
                      opacity: wasSynchronous || frame != null ? 1 : 0,
                      duration: AnimationConstants.imageFade,
                      curve: Curves.easeOut,
                      child: child,
                    ),
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
            if (action != null)
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: action!,
              ),
          ],
        ),
      ),
    );
  }
}
