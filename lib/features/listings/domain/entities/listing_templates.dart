import 'package:sokosafi/features/listings/domain/entities/listing.dart';

/// "Recent templates" on the create screen: the business's latest listings,
/// one per product name, so a daily item can be relisted in one tap.
abstract final class ListingTemplates {
  static const int maxTemplates = 6;

  /// [listings] must be newest first, as the repository streams them.
  static List<Listing> recent(List<Listing> listings) {
    final seenTitles = <String>{};
    final templates = <Listing>[];
    for (final listing in listings) {
      final key = listing.title.trim().toLowerCase();
      if (key.isEmpty || !seenTitles.add(key)) continue;
      templates.add(listing);
      if (templates.length == maxTemplates) break;
    }
    return templates;
  }
}
