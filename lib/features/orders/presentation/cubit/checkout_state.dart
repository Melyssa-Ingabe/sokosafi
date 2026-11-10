part of 'checkout_cubit.dart';

enum CheckoutStatus { loading, ready, failure }

class CheckoutState extends Equatable {
  const CheckoutState({
    required this.paymentMethod,
    this.status = CheckoutStatus.loading,
    this.item,
    this.quantity = 1,
    this.isSubmitting = false,
    this.errorMessage,
    this.placedOrderId,
  });

  final CheckoutStatus status;
  final CheckoutItem? item;
  final int quantity;
  final PaymentMethod paymentMethod;
  final bool isSubmitting;

  /// Set when loading fails, or when the last submit failed.
  final String? errorMessage;

  /// Set once the order exists, so the screen can move on.
  final String? placedOrderId;

  int get maxQuantity => item?.listing.quantityLeft ?? 0;
  bool get canIncrease => quantity < maxQuantity;
  bool get canDecrease => quantity > 1;

  num get originalTotal => (item?.listing.originalPrice ?? 0) * quantity;
  num get total => (item?.listing.discountPrice ?? 0) * quantity;
  num get discount => originalTotal - total;

  CheckoutState copyWith({
    CheckoutStatus? status,
    CheckoutItem? item,
    int? quantity,
    PaymentMethod? paymentMethod,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? placedOrderId,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      placedOrderId: placedOrderId ?? this.placedOrderId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    item,
    quantity,
    paymentMethod,
    isSubmitting,
    errorMessage,
    placedOrderId,
  ];
}
