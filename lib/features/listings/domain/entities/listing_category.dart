/// The food groups a listing can belong to. The customer feed groups
/// listings by these, so the stored names must stay stable.
enum ListingCategory {
  bakery('Bakery'),
  meals('Meals'),
  cafe('Café'),
  grocery('Grocery');

  const ListingCategory(this.label);

  final String label;

  /// Reads the category stored in Firestore, defaulting to meals when it is
  /// missing or unrecognised.
  static ListingCategory fromName(String? name) {
    return ListingCategory.values.firstWhere(
      (category) => category.name == name,
      orElse: () => ListingCategory.meals,
    );
  }
}
