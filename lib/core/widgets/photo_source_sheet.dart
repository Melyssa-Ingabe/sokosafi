import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/storage/photo_picker.dart';

/// Bottom sheet asking whether to take a photo or choose one.
class PhotoSourceSheet extends StatelessWidget {
  const PhotoSourceSheet({super.key});

  /// Returns the chosen source, or null when the sheet is dismissed.
  static Future<PhotoSource?> show(BuildContext context) {
    return showModalBottomSheet<PhotoSource>(
      context: context,
      showDragHandle: true,
      builder: (_) => const PhotoSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.primary;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              child: Text('Add a photo', style: theme.textTheme.titleMedium),
            ),
            ListTile(
              minTileHeight: AppSpacing.minTapTarget + AppSpacing.sm,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
              ),
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedCamera01,
                color: iconColor,
              ),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(context).pop(PhotoSource.camera),
            ),
            ListTile(
              minTileHeight: AppSpacing.minTapTarget + AppSpacing.sm,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
              ),
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedImage01,
                color: iconColor,
              ),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(PhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
