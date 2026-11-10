import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';

/// Lets the user pick one value from a short list. Returns null when the
/// sheet is dismissed.
Future<T?> showOptionsSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T option) labelOf,
}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
            for (final option in options)
              ListTile(
                minTileHeight: AppSpacing.minTapTarget + AppSpacing.sm,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                ),
                title: Text(labelOf(option)),
                trailing: option == selected
                    ? HugeIcon(
                        icon: HugeIcons.strokeRoundedTick02,
                        color: theme.colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(option),
              ),
          ],
        ),
      );
    },
  );
}
