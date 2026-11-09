import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/theme/app_colors.dart';

/// Thin progress bar that slides to the new value when the step changes.
class SetupProgressBar extends StatelessWidget {
  const SetupProgressBar({super.key, required this.progress});

  /// Between 0 and 1.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 4,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress),
          duration: AnimationConstants.pageTransition,
          curve: AnimationConstants.pageCurve,
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.surfaceSubtle,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
