part of 'listing_bloc.dart';

enum ListingsStatus { loading, success, failure }

class ListingState extends Equatable {
  const ListingState({
    this.status = ListingsStatus.loading,
    this.businessId = '',
    this.listings = const <Listing>[],
    this.deletingIds = const <String>{},
    this.errorMessage,
    this.feedback,
  });

  final ListingsStatus status;
  final String businessId;
  final List<Listing> listings;

  /// Listings with a delete in flight, so their cards can show progress and
  /// ignore a second tap.
  final Set<String> deletingIds;

  /// Why the list could not be loaded, shown in place of the list.
  final String? errorMessage;
  final FeedbackMessage? feedback;

  ListingState copyWith({
    ListingsStatus? status,
    String? businessId,
    List<Listing>? listings,
    Set<String>? deletingIds,
    String? errorMessage,
    bool clearError = false,
    FeedbackMessage? feedback,
  }) {
    return ListingState(
      status: status ?? this.status,
      businessId: businessId ?? this.businessId,
      listings: listings ?? this.listings,
      deletingIds: deletingIds ?? this.deletingIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      // Feedback is shown once, so it is never carried into the next state.
      feedback: feedback,
    );
  }

  @override
  List<Object?> get props => [
    status,
    businessId,
    listings,
    deletingIds,
    errorMessage,
    feedback,
  ];
}
