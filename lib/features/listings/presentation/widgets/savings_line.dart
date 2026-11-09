import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';

/// "Customers save 40%", shown once both prices make a real discount.
class SavingsLine extends StatelessWidget {
  const SavingsLine({super.key, required this.percent});

  final int? percent;

  @override
  Widget build(BuildContext context) {
    final value = percent;
    return AnimatedSwitcher(
      duration: AnimationConstants.listItem,
      switchInCurve: AnimationConstants.listCurve,
      child: value == null
          ? const SizedBox.shrink()
          : Padding(
              key: ValueKey(value),
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Row(
                children: [
                  const SizedBox.square(
                    dimension: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Customers save $value%',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
    );
  }
}
