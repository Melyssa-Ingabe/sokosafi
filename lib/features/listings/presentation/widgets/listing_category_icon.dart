import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

/// The icon for each listing category, kept out of the domain layer.
extension ListingCategoryIcon on ListingCategory {
  List<List<dynamic>> get icon => switch (this) {
    ListingCategory.bakery => HugeIcons.strokeRoundedCroissant,
    ListingCategory.meals => HugeIcons.strokeRoundedRestaurant01,
    ListingCategory.cafe => HugeIcons.strokeRoundedCoffee01,
    ListingCategory.grocery => HugeIcons.strokeRoundedShoppingBasket01,
  };
}
