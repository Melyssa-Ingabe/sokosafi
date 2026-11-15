import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/core/widgets/countdown_text.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_status.dart';
import 'package:sokosafi/features/listings/presentation/widgets/listing_status_badge.dart';
import 'package:sokosafi/features/listings/presentation/widgets/listing_thumbnail.dart';

/// One of the owner's listings, with its status and edit and delete actions.
class ManagedListingCard extends StatelessWidget {
  const ManagedListingCard({
    super.key,
    required this.listing,
    required this.status,
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  final Listing listing;

  /// The status as of now, which may be expired even if the stored status
  /// still says active.
  final ListingStatus status;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final mutedColor = theme.colorScheme.onSurfaceVariant;

    return TapScale(
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isDeleting ? null : onEdit,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                Formatters.rwf(listing.discountPrice),
                                style: textTheme.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                Formatters.rwf(listing.originalPrice),
                                style: textTheme.bodySmall?.copyWith(
                                  color: mutedColor,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: Text(
                        '${listing.quantity} left',
                        style: textTheme.bodyMedium?.copyWith(
                          color: mutedColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedClock01,
                      size: 18,
                      color: mutedColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: status == ListingStatus.active
                          ? CountdownText(
                              deadline: listing.pickupBy,
                              style: textTheme.bodyMedium?.copyWith(
                                color: mutedColor,
                              ),
                            )
                          : Text(
                              status == ListingStatus.soldOut
                                  ? 'Everything was reserved'
                                  : 'Pick-up time has passed',
                              style: textTheme.bodyMedium?.copyWith(
                                color: mutedColor,
                              ),
                            ),
                    ),
                    ListingStatusBadge(status: status),
                  ],
                ),
                const Divider(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: isDeleting ? null : onEdit,
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedPencilEdit01,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    isDeleting
                        ? const Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : TextButton.icon(
                            onPressed: onDelete,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedDelete02,
                              size: 18,
                              color: AppColors.error,
                            ),
                            label: const Text('Delete'),
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
