import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

/// One horizontal row of the feed, such as "Ending soon" or "Bakery".
class FeedSection extends Equatable {
  const FeedSection({required this.title, required this.items, this.category});

  final String title;
  final List<FeedItem> items;

  /// The category this row shows, or null for the "Ending soon" row.
  final ListingCategory? category;

  @override
  List<Object?> get props => [title, items, category];
}
