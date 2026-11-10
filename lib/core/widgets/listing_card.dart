import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/core/widgets/app_badge.dart';
import 'package:sokosafi/core/widgets/countdown_text.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';

/// Card for one surplus-food listing. It takes plain values rather than a
/// model, so it does not depend on the listings feature.
class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.title,
    required this.businessName,
    required this.originalPrice,
    required this.discountPrice,
    required this.quantityLeft,
    required this.pickupBy,
    this.imageUrl,
    this.distanceText,
    this.heroTag,
    this.onTap,
  });

  final String title;
  final String businessName;
  final num originalPrice;
  final num discountPrice;
  final int quantityLeft;
  final DateTime pickupBy;
  final String? imageUrl;
  final String? distanceText;
  final Object? heroTag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scheme = theme.colorScheme;
    final isSoldOut = quantityLeft <= 0;
    final percentOff = Formatters.discountPercent(
      original: originalPrice,
      discounted: discountPrice,
    );

    return TapScale(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 6,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isSoldOut ? null : onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    _buildImage(scheme),
                    if (percentOff > 0)
                      Positioned(
                        top: AppSpacing.sm,
                        left: AppSpacing.sm,
                        child: AppBadge(label: '-$percentOff%'),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium,
                      ),
                      Text(
                        businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        children: [
                          Text(
                            Formatters.rwf(discountPrice),
                            style: textTheme.labelMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            Formatters.rwf(originalPrice),
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isSoldOut ? 'Sold out' : '$quantityLeft left',
                              style: textTheme.bodySmall?.copyWith(
                                color: isSoldOut ? scheme.error : null,
                              ),
                            ),
                          ),
                          if (!isSoldOut)
                            CountdownText(
                              deadline: pickupBy,
                              style: textTheme.bodySmall,
                            ),
                        ],
                      ),
                      if (distanceText != null)
                        Text(
                          distanceText!,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(ColorScheme scheme) {
    final placeholder = ColoredBox(color: scheme.surfaceContainerHighest);
    final url = imageUrl;
    final Widget content = (url == null || url.isEmpty)
        ? placeholder
        : Image.network(
            url,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, loadedSynchronously) {
              if (loadedSynchronously) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: AnimationConstants.imageFade,
                curve: AnimationConstants.imageFadeCurve,
                child: child,
              );
            },
            errorBuilder: (context, error, stackTrace) => placeholder,
          );
    final image = SizedBox(height: 100, width: double.infinity, child: content);
    return heroTag == null ? image : Hero(tag: heroTag!, child: image);
  }
}
