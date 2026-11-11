import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/theme/app_text_styles.dart';
import 'package:sokosafi/core/widgets/app_badge.dart';
import 'package:sokosafi/core/widgets/countdown_text.dart';
import 'package:sokosafi/features/business_dashboard/domain/entities/dashboard_summary.dart';
import 'package:sokosafi/features/listings/presentation/widgets/listing_category_icon.dart';

/// An active listing with how much is left, a progress bar, the time left
/// to pick up and how many portions are reserved.
class ListingProgressCard extends StatelessWidget {
  const ListingProgressCard({super.key, required this.progress});

  final ListingProgress progress;

  @override
  Widget build(BuildContext context) {
    final listing = progress.listing;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: listing.category.icon,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    listing.title,
                    style: AppTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${progress.left}/${progress.totalPortions} left',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // The bar grows from empty to its value when the card appears.
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.orderedFraction),
              duration: AnimationConstants.pageTransition,
              curve: AnimationConstants.pageCurve,
              builder: (context, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.xs),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.brandSubtle,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedClock01,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: CountdownText(
                    deadline: listing.pickupBy,
                    style: AppTextStyles.caption,
                  ),
                ),
                AppBadge(
                  label: '${progress.reserved} reserved',
                  backgroundColor: AppColors.brandSubtle,
                  foregroundColor: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
