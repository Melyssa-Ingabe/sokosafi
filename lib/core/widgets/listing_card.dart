import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
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
            side: const BorderSide(color: AppColors.borderSubtle),
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
                        if (!isSoldOut)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: _AddBadge(),
                          ),
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
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderSubtle,
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
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11,
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
    const placeholder = ColoredBox(color: AppColors.surfaceSubtle);
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

/// The white "+" in the photo's corner. Decorative: the whole card is the
/// button, so screen readers skip it.
class _AddBadge extends StatelessWidget {
  const _AddBadge();

  static const double _size = 28;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedAdd01,
          size: 14,
          color: AppColors.textPrimary,
        ),
      ),
    );
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
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontSize: 10, height: 1.4, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
