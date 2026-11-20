import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';

/// The listing photo as a rounded card at the top of the detail screen,
/// with a back button over it. Shares a hero tag with the card it was
/// opened from.
class ProductPhotoHeader extends StatelessWidget {
  const ProductPhotoHeader({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.action,
  });

  final String imageUrl;
  final Object? heroTag;

  /// Shown in the top-right corner, where Figma has its round button.
  final Widget? action;

  // Sizes from the Product Detail frame in Figma.
  static const double height = 268;
  static const double _radius = 24;
  static const double _buttonSize = 40;

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
    final Widget photo = imageUrl.isEmpty
        ? placeholder
        : Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => placeholder,
          );
    final tag = heroTag;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              tag == null ? photo : Hero(tag: tag, child: photo),
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                // A 40px circle like Figma's, inside a 48px tap target.
                child: IconButton(
                  tooltip: 'Back',
                  style: IconButton.styleFrom(
                    fixedSize: const Size.square(AppSpacing.minTapTarget),
                  ),
                  onPressed: () => context.pop(),
                  icon: Container(
                    width: _buttonSize,
                    height: _buttonSize,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
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
      ),
    );
  }
}
