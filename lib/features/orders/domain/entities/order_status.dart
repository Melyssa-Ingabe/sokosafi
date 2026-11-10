enum OrderStatus {
  paid,
  collected,
  cancelled;

  static OrderStatus fromName(String? name) {
    return OrderStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => OrderStatus.paid,
    );
  }
}
