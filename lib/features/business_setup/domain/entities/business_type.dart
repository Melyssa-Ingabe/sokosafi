/// Kinds of food business that can sell on SokoSafi. The list is fixed on
/// purpose: only places that prepare or sell food that is safe to eat, and
/// fixed names keep the customer filters consistent. Raw meat and fish
/// sellers are left out because their surplus is not safe to resell.
enum BusinessType {
  bakery('Bakery'),
  restaurant('Restaurant'),
  cafe('Café'),
  supermarket('Supermarket'),
  hotel('Hotel'),
  cafeteria('Cafeteria'),
  grocery('Grocery'),
  catering('Catering');

  const BusinessType(this.label);

  final String label;

  /// Reads the type stored in Firestore, or null when it is missing or not
  /// one of the known types.
  static BusinessType? fromName(String? name) {
    for (final type in BusinessType.values) {
      if (type.name == name) return type;
    }
    return null;
  }
}
