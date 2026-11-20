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

  /// Opens a listing. The hero tag lets its photo fly to the detail screen.
  final void Function(FeedItem item, String heroTag) onOpen;

  // Card size and spacing from the Customer/Feed frame in Figma.
  static const double cardWidth = 168;
  static const double cardGap = 14;
  static const double sidePadding = 20;

  /// The same listing can sit in "Ending soon" and in its category row, so
  /// the row title is part of the tag to keep every hero tag unique.
  String heroTagFor(FeedItem item) =>
      'feed-${section.title}-${item.listing.id}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: sidePadding),
          child: SectionHeader(title: section.title),
        ),
        const SizedBox(height: AppSpacing.sm),
        // A Row inside a scroll view sizes itself to its tallest card, so
        // larger text never overflows a fixed row height.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: sidePadding,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in section.items)
                Padding(
                  padding: const EdgeInsets.only(right: cardGap),
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
                      heroTag: heroTagFor(item),
                      onTap: () => onOpen(item, heroTagFor(item)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
