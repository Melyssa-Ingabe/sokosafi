import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';

/// "Add product photo" card. Shows the picked photo, or the listing's
/// current photo when editing.
class ListingPhotoField extends StatelessWidget {
  const ListingPhotoField({
    super.key,
    required this.photoPath,
    required this.imageUrl,
    required this.onTap,
  });

  final String? photoPath;
  final String imageUrl;
  final VoidCallback onTap;

  static const double height = 180;

  Widget _fadeIn(Widget child, int? frame, bool wasSynchronouslyLoaded) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: AnimationConstants.imageFade,
      curve: AnimationConstants.imageFadeCurve,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = photoPath;
    final Widget? image = path != null
        ? Image.file(
            File(path),
            fit: BoxFit.cover,
            frameBuilder: (_, child, frame, wasSync) =>
                _fadeIn(child, frame, wasSync),
          )
        : imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            frameBuilder: (_, child, frame, wasSync) =>
                _fadeIn(child, frame, wasSync),
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          )
        : null;

    return Semantics(
      button: true,
      label: image == null ? 'Add product photo' : 'Change product photo',
      child: TapScale(
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: image != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        image,
                        Positioned(
                          right: AppSpacing.md,
                          bottom: AppSpacing.md,
                          child: Material(
                            color: AppColors.surface,
                            shape: const CircleBorder(),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedPencilEdit01,
                                color: theme.colorScheme.onSurface,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedCamera01,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Add product photo',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Clear photos help your food sell faster',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
