import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_type.dart';

/// The icon shown for each business type. Kept in the presentation layer so
/// the domain stays free of Flutter.
extension BusinessTypeIcon on BusinessType {
  List<List<dynamic>> get icon => switch (this) {
    BusinessType.bakery => HugeIcons.strokeRoundedCroissant,
    BusinessType.restaurant => HugeIcons.strokeRoundedRestaurant01,
    BusinessType.cafe => HugeIcons.strokeRoundedCoffee01,
    BusinessType.supermarket => HugeIcons.strokeRoundedStore01,
    BusinessType.hotel => HugeIcons.strokeRoundedBed,
    BusinessType.cafeteria => HugeIcons.strokeRoundedHamburger01,
    BusinessType.grocery => HugeIcons.strokeRoundedShoppingBasket01,
    BusinessType.catering => HugeIcons.strokeRoundedChefHat,
  };
}
