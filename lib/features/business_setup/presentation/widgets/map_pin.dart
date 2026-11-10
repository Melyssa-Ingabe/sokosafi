import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/theme/app_colors.dart';

/// The pin drawn over the middle of the map. Its tip sits exactly on the map
/// center, which is the position that gets saved.
class MapPin extends StatelessWidget {
  const MapPin({super.key});

  static const double size = 44;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        // Lifts the pin so its tip, not its middle, marks the center.
        padding: const EdgeInsets.only(bottom: size),
        child: SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                color: AppColors.primary,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
