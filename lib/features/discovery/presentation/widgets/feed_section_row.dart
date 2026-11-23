import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/listing_card.dart';
import 'package:sokosafi/core/widgets/section_header.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_section.dart';

/// A titled row of listing cards that scrolls sideways.
class FeedSectionRow extends StatelessWidget {
  const FeedSectionRow({
    super.key,
    required this.section,
    required this.distanceTo,
    required this.onOpen,
  });

  final FeedSection section;

  /// "350 m away", or null while the customer's location is unknown.
  final String? Function(Business business) distanceTo;

  final void Function(FeedItem item) onOpen;

  static const double cardGap = AppSpacing.md;

  /// Two full cards plus this share of a third fit on screen, so the
  /// peeking card hints that the row scrolls.
  static const double _visibleCards = 2.15;

  static double cardWidthFor(double rowWidth) {
    final usable = rowWidth - AppSpacing.pagePadding - cardGap * 2;
    return usable / _visibleCards;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
          ),
          child: SectionHeader(title: section.title),
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = cardWidthFor(constraints.maxWidth);
            // A Row inside a scroll view sizes itself to its tallest card,
            // so larger text never overflows a fixed row height.
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (index, item) in section.items.indexed)
                    Padding(
                      padding: EdgeInsets.only(
                        right: index == section.items.length - 1 ? 0 : cardGap,
                      ),
                      child: SizedBox(
                        width: cardWidth,
                        child: ListingCard(
                          title: item.listing.title,
                          businessName: item.business.name,
                          originalPrice: item.listing.originalPrice,
                          discountPrice: item.listing.discountPrice,
                          quantityLeft: item.listing.quantity,
                          pickupBy: item.listing.pickupBy,
                          imageUrl: item.listing.imageUrl,
                          distanceText: distanceTo(item.business),
                          onTap: () => onOpen(item),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
