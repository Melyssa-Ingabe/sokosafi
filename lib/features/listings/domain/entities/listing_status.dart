/// Lifecycle of a listing. Stored in Firestore by name: active, soldOut,
/// expired.
enum ListingStatus {
  active,
  soldOut,
  expired;

  static ListingStatus fromName(String? name) {
    return ListingStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => ListingStatus.active,
    );
  }

  /// The status to save after a create or edit: a listing with nothing left
  /// is sold out, otherwise it is back on sale.
  static ListingStatus forQuantity(int quantity) {
    return quantity <= 0 ? ListingStatus.soldOut : ListingStatus.active;
  }
}
