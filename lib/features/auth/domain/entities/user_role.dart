/// Whether the account buys surplus food or sells it.
enum UserRole {
  customer,
  business;

  /// Reads the role stored in Firestore, defaulting to customer when it is
  /// missing or unrecognised.
  static UserRole fromName(String? name) {
    return UserRole.values.firstWhere(
      (role) => role.name == name,
      orElse: () => UserRole.customer,
    );
  }
}
