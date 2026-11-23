import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/app_badge.dart';
import 'package:sokosafi/core/widgets/countdown_text.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';
import 'package:sokosafi/features/business_dashboard/domain/entities/dashboard_summary.dart';
import 'package:sokosafi/features/listings/presentation/widgets/listing_thumbnail.dart';

/// An active listing with how much is left, a progress bar, the time left
/// to pick up and how many portions are reserved.
class ListingProgressCard extends StatelessWidget {
  const ListingProgressCard({super.key, required this.progress, this.onTap});

  final ListingProgress progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final listing = progress.listing;
    return TapScale(
      child: Material(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ListingThumbnail(
                      imageUrl: listing.imageUrl,
                      category: listing.category,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        listing.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${progress.left}/${progress.totalPortions} left',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // The bar fills from empty when the card appears.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1 - progress.orderedFraction),
                  duration: const Duration(milliseconds: 600),
                  curve: AnimationConstants.listCurve,
                  builder: (context, value, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 4,
                      backgroundColor: scheme.surfaceContainerHighest,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CountdownText(
                          deadline: listing.pickupBy,
                          showIcon: true,
                          urgentColor: AppColors.error,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    AppBadge(
                      label: '${progress.reserved} reserved',
                      showDot: true,
                      backgroundColor: scheme.surfaceContainerHighest,
                      foregroundColor: scheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
