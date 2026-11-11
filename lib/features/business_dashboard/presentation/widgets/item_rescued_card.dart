import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/theme/app_text_styles.dart';

/// The food-waste-diverted tracker: portions customers actually collected.
class ItemsRescuedCard extends StatelessWidget {
  const ItemsRescuedCard({super.key, required this.itemsRescued});

  final int itemsRescued;

  @override
  Widget build(BuildContext context) {
    final message = itemsRescued == 0
        ? 'Portions customers pick up will be counted here as food saved '
              'from waste.'
        : "You've saved $itemsRescued "
              '${itemsRescued == 1 ? 'portion' : 'portions'} of food from '
              'going to waste.';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.brandSubtle,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedLeaf01,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
