part of 'product_detail_cubit.dart';

enum ProductDetailStatus { loading, ready, failure }

class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductDetailStatus.loading,
    this.item,
    this.quantity = 1,
    this.errorMessage,
  });

  final ProductDetailStatus status;
  final FeedItem? item;
  final int quantity;
  final String? errorMessage;

  int get quantityLeft => item?.listing.quantity ?? 0;
  bool get canIncrease => quantity < quantityLeft;
  bool get canDecrease => quantity > 1;
  int get total => (item?.listing.discountPrice ?? 0) * quantity;

  /// Whether the Reserve button should work at [now].
  bool canReserveAt(DateTime now) => item?.isAvailableAt(now) ?? false;

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    FeedItem? item,
    int? quantity,
    String? errorMessage,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, item, quantity, errorMessage];
}
