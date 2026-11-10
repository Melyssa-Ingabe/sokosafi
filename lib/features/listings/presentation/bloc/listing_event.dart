part of 'listing_bloc.dart';

sealed class ListingEvent extends Equatable {
  const ListingEvent();

  @override
  List<Object?> get props => [];
}

/// Starts following the listings of one business.
final class ListingsSubscriptionRequested extends ListingEvent {
  const ListingsSubscriptionRequested(this.businessId);

  final String businessId;

  @override
  List<Object?> get props => [businessId];
}

/// Sent after the owner confirms the delete dialog.
final class ListingDeleteRequested extends ListingEvent {
  const ListingDeleteRequested(this.listingId);

  final String listingId;

  @override
  List<Object?> get props => [listingId];
}
