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

  /// Keeps the grey box and a spinner behind the photo until it has
  /// loaded, then fades the photo in over them.
  Widget _fadeIn(Widget child, int? frame, bool wasSynchronouslyLoaded) {
    if (wasSynchronouslyLoaded) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (frame == null)
          ColoredBox(
            color: AppColors.surfaceSubtle,
            child: Center(
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: AnimationConstants.imageFade,
          curve: AnimationConstants.imageFadeCurve,
          child: child,
        ),
      ],
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
            errorBuilder: (_, _, _) => ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: Text(
                  'Photo could not load. Tap to change it',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        : null;

    return Semantics(
      button: true,
      label: image == null ? 'Add product photo' : 'Change product photo',
      child: TapScale(
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
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
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest,
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
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedCamera01,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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
