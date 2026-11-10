import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';

/// Square photo box: an "add photo" prompt when empty, the picked photo with
/// an edit badge when filled.
class PhotoPreview extends StatelessWidget {
  const PhotoPreview({super.key, required this.photoPath, required this.onTap});

  final String? photoPath;
  final VoidCallback onTap;

  static const double size = 200;
  static const double radius = 32;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = photoPath;
    return Semantics(
      button: true,
      label: path == null ? 'Add a photo' : 'Change photo',
      child: TapScale(
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox.square(
            dimension: size + AppSpacing.lg,
            child: Stack(
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: path == null ? AppColors.border : AppColors.accent,
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: path == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedCamera01,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 36,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Tap to add a photo',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                      : Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          frameBuilder: (context, child, frame, wasSync) {
                            if (wasSync) return child;
                            return AnimatedOpacity(
                              opacity: frame == null ? 0 : 1,
                              duration: AnimationConstants.imageFade,
                              curve: AnimationConstants.imageFadeCurve,
                              child: child,
                            );
                          },
                        ),
                ),
                if (path != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
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
            ),
          ),
        ),
      ),
    );
  }
}
