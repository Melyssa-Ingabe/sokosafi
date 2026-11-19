part of 'shop_listings_cubit.dart';

enum ShopListingsStatus { loading, ready, failure }

class ShopListingsState extends Equatable {
  const ShopListingsState({
    this.status = ShopListingsStatus.loading,
    this.items = const [],
    this.errorMessage,
  });

  final ShopListingsStatus status;
  final List<FeedItem> items;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, items, errorMessage];
}
