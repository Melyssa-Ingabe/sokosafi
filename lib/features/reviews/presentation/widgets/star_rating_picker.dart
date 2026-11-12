import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';

/// Five tappable stars. Chosen stars are drawn in the brand colour with a
/// heavier stroke.
class StarRatingPicker extends StatelessWidget {
  const StarRatingPicker({
    super.key,
    required this.rating,
    required this.onRate,
    this.enabled = true,
  });

  final int rating;
  final ValueChanged<int> onRate;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var star = 1; star <= 5; star++)
          Semantics(
            button: true,
            selected: star <= rating,
            label: '$star ${star == 1 ? 'star' : 'stars'}',
            child: TapScale(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: enabled
                    ? () {
                        HapticFeedback.selectionClick();
                        onRate(star);
                      }
                    : null,
                child: SizedBox.square(
                  dimension: AppSpacing.minTapTarget,
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedStar,
                      size: 36,
                      strokeWidth: star <= rating ? 2.5 : 1.5,
                      color: star <= rating
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
