import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';

/// The "+" and "-" card in the corner of the map.
class MapZoomButtons extends StatelessWidget {
  const MapZoomButtons({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: AppColors.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Zoom in',
            onPressed: onZoomIn,
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              color: iconColor,
            ),
          ),
          const SizedBox(
            width: AppSpacing.xl,
            child: Divider(height: 1, color: AppColors.borderSubtle),
          ),
          IconButton(
            tooltip: 'Zoom out',
            onPressed: onZoomOut,
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedMinusSign,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}
