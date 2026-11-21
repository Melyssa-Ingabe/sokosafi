import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/core/widgets/app_badge.dart';
import 'package:sokosafi/core/widgets/now_ticker.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';
import 'package:sokosafi/features/discovery/domain/geo_distance.dart';
import 'package:sokosafi/features/discovery/domain/search_results.dart';

/// One result on the Search screen, from the "Near you" cards in Figma.
class SearchResultCard extends StatelessWidget {
  const SearchResultCard({
    super.key,
    required this.result,
    required this.heroTag,
    required this.onTap,
  });

  final SearchResult result;
  final Object heroTag;
  final VoidCallback onTap;

  static const double _radius = 18;
  static const double _photoHeight = 120;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final listing = result.item.listing;
    final distance = result.distanceKm;
    final percentOff = Formatters.discountPercent(
      original: listing.originalPrice,
      discounted: listing.discountPrice,
    );

    return TapScale(
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: _photoHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: heroTag,
                      child: _Photo(url: listing.imageUrl),
                    ),
                    if (percentOff > 0)
                      Positioned(
                        left: AppSpacing.sm,
                        bottom: AppSpacing.sm,
                        child: AppBadge(label: '-$percentOff%'),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            result.item.business.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (distance != null)
                          Text(
                            GeoDistance.label(distance),
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '${listing.quantity} × ${listing.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                Formatters.rwf(listing.discountPrice),
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                Formatters.rwf(listing.originalPrice),
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _TimeLeftChip(pickupBy: listing.pickupBy),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "1h 24m left", turning red in the last half hour.
class _TimeLeftChip extends StatelessWidget {
  const _TimeLeftChip({required this.pickupBy});

  final DateTime pickupBy;

  static const Duration _urgentWithin = Duration(minutes: 30);

  @override
  Widget build(BuildContext context) {
    return NowTicker(
      builder: (context, now) {
        final remaining = pickupBy.difference(now);
        final isUrgent = remaining < _urgentWithin;
        final color = isUrgent ? AppColors.error : AppColors.textSecondary;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: isUrgent ? AppColors.errorSubtle : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedClock01,
                  size: 13,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  Formatters.timeLeft(remaining),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: color, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(color: AppColors.surfaceSubtle);
    if (url.isEmpty) return placeholder;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}
