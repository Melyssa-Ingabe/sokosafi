import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/failures/listing_failure.dart';
import 'package:sokosafi/features/listings/domain/repositories/listing_repository.dart';
import 'package:sokosafi/features/listings/presentation/bloc/listing_feedback.dart';

part 'listing_event.dart';
part 'listing_state.dart';

/// Live list of a business's listings, plus deleting them. Creating and
/// editing go through ListingFormCubit; the new data reaches this list
/// through the Firestore stream, with no manual refresh.
class ListingBloc extends Bloc<ListingEvent, ListingState> {
  ListingBloc({required this._listingRepository})
    : super(const ListingState()) {
    on<ListingsSubscriptionRequested>(_onSubscriptionRequested);
    on<ListingDeleteRequested>(_onDeleteRequested);
  }

  final ListingRepository _listingRepository;

  Future<void> _onSubscriptionRequested(
    ListingsSubscriptionRequested event,
    Emitter<ListingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ListingsStatus.loading,
        businessId: event.businessId,
        clearError: true,
      ),
    );
    await emit.forEach<List<Listing>>(
      _listingRepository.watchBusinessListings(event.businessId),
      onData: (listings) => state.copyWith(
        status: ListingsStatus.success,
        listings: listings,
        clearError: true,
      ),
      onError: (error, _) => state.copyWith(
        status: ListingsStatus.failure,
        errorMessage: _messageFor(error),
      ),
    );
  }

  Future<void> _onDeleteRequested(
    ListingDeleteRequested event,
    Emitter<ListingState> emit,
  ) async {
    if (state.deletingIds.contains(event.listingId)) return;
    emit(state.copyWith(deletingIds: {...state.deletingIds, event.listingId}));
    try {
      await _listingRepository.deleteListing(
        businessId: state.businessId,
        listingId: event.listingId,
      );
      emit(
        state.copyWith(
          deletingIds: _without(event.listingId),
          feedback: ListingFeedback.success('Listing deleted'),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          deletingIds: _without(event.listingId),
          feedback: ListingFeedback.error(_messageFor(error)),
        ),
      );
    }
  }

  Set<String> _without(String listingId) =>
      state.deletingIds.where((id) => id != listingId).toSet();

  String _messageFor(Object error) =>
      error is ListingFailure ? error.message : ListingFailure.genericMessage;
}
