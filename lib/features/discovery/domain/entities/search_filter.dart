import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

/// What the customer is looking for on the Search screen. Every part is
/// optional; an empty filter matches everything on sale.
class SearchFilter extends Equatable {
  const SearchFilter({
    this.query = '',
    this.category,
    this.maxPriceRwf,
    this.radiusKm,
  });

  /// Matched against the food, its description, the shop and the category.
  final String query;
  final ListingCategory? category;

  /// Highest discounted price to show, or null for any price.
  final int? maxPriceRwf;

  /// How far away a shop may be, or null for any distance. Only applied
  /// once the phone has shared where the customer is.
  final int? radiusKm;

  /// Price limits offered on the filter sheet, in RWF.
  static const List<int> priceOptionsRwf = [500, 1000, 2000, 5000];

  /// Whether anything beyond the search text narrows the results, for the
  /// badge on the filter button.
  bool get hasFilters =>
      category != null || maxPriceRwf != null || radiusKm != null;

  SearchFilter copyWith({
    String? query,
    ListingCategory? category,
    bool clearCategory = false,
    int? maxPriceRwf,
    bool clearMaxPrice = false,
    int? radiusKm,
    bool clearRadius = false,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      maxPriceRwf: clearMaxPrice ? null : (maxPriceRwf ?? this.maxPriceRwf),
      radiusKm: clearRadius ? null : (radiusKm ?? this.radiusKm),
    );
  }

  @override
  List<Object?> get props => [query, category, maxPriceRwf, radiusKm];
}
