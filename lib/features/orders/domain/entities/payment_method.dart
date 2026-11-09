/// Mobile money options offered at checkout.
enum PaymentMethod {
  mtnMomo('MTN Mobile Money'),
  airtelMoney('Airtel Money');

  const PaymentMethod(this.label);

  final String label;

  /// Reads a stored name, defaulting to MTN when it is missing or unknown.
  static PaymentMethod fromName(String? name) {
    return PaymentMethod.values.firstWhere(
      (method) => method.name == name,
      orElse: () => PaymentMethod.mtnMomo,
    );
  }
}
