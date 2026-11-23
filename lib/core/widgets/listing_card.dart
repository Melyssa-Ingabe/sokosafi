import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/utils/date_formatters.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';

/// Card for one surplus-food listing, matching "Product card/Standard" in
/// Figma. It takes plain values rather than a model, so it does not depend
/// on the listings feature.
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

  static const double _radius = 18;
  static const double _padding = 10;
  static const double _imageHeight = 100;
  static const double _imageRadius = 14;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isSoldOut = quantityLeft <= 0;
    final details = [
      isSoldOut ? 'Sold out' : '$quantityLeft left',
      ?distanceText,
    ].join(' · ');

    return TapScale(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: scheme.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: InkWell(
            onTap: isSoldOut ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.all(_padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(_imageRadius),
                    child: Stack(
                      children: [
                        _buildImage(scheme),
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: _PickupChip(
                            label: isSoldOut
                                ? 'Sold out'
                                : 'Until ${DateFormatters.time(pickupBy)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _padding),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          businessName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          details,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: isSoldOut
                                ? scheme.error
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _padding),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 9),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            Formatters.rwf(discountPrice),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          Formatters.rwf(originalPrice),
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
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
    final image = SizedBox(
      height: _imageHeight,
      width: double.infinity,
      child: content,
    );
    return heroTag == null ? image : Hero(tag: heroTag!, child: image);
  }
}

/// The dark "Until 9:00 PM" chip over the photo.
class _PickupChip extends StatelessWidget {
  const _PickupChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedClock01,
              size: 10,
              color: Colors.white,
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
