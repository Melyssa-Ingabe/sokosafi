import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/domain/failures/listing_failure.dart';
import 'package:sokosafi/features/listings/domain/repositories/listing_repository.dart';
import 'package:sokosafi/features/listings/presentation/bloc/listing_bloc.dart';

import '../../listing_test_data.dart';

class MockListingRepository extends Mock implements ListingRepository {}

void main() {
  late MockListingRepository repository;
  final listing = buildTestListing();

  setUp(() {
    repository = MockListingRepository();
  });

  blocTest<ListingBloc, ListingState>(
    'shows the business listings streamed from the repository',
    build: () {
      when(() => repository.watchBusinessListings(testBusinessId))
          .thenAnswer((_) => Stream<List<Listing>>.value([listing]));
      return ListingBloc(listingRepository: repository);
    },
    act: (bloc) =>
        bloc.add(const ListingsSubscriptionRequested(testBusinessId)),
    expect: () => [
      const ListingState(businessId: testBusinessId),
      ListingState(
        status: ListingsStatus.success,
        businessId: testBusinessId,
        listings: [listing],
      ),
    ],
  );

  blocTest<ListingBloc, ListingState>(
    'shows a polite error when the listings cannot be loaded',
    build: () {
      when(() => repository.watchBusinessListings(testBusinessId)).thenAnswer(
        (_) => Stream<List<Listing>>.error(
          const ListingFailure('You seem to be offline'),
        ),
      );
      return ListingBloc(listingRepository: repository);
    },
    act: (bloc) =>
        bloc.add(const ListingsSubscriptionRequested(testBusinessId)),
    expect: () => [
      const ListingState(businessId: testBusinessId),
      const ListingState(
        status: ListingsStatus.failure,
        businessId: testBusinessId,
        errorMessage: 'You seem to be offline',
      ),
    ],
  );

  blocTest<ListingBloc, ListingState>(
    'confirms with "Listing deleted" after a successful delete',
    build: () {
      when(
        () => repository.deleteListing(
          businessId: testBusinessId,
          listingId: listing.id,
        ),
      ).thenAnswer((_) async {});
      return ListingBloc(listingRepository: repository);
    },
    seed: () => ListingState(
      status: ListingsStatus.success,
      businessId: testBusinessId,
      listings: [listing],
    ),
    act: (bloc) => bloc.add(ListingDeleteRequested(listing.id)),
    expect: () => [
      isA<ListingState>().having((state) => state.deletingIds, 'deletingIds', {
        listing.id,
      }),
      isA<ListingState>()
          .having((state) => state.deletingIds, 'deletingIds', isEmpty)
          .having(
            (state) => state.feedback?.message,
            'message',
            'Listing deleted',
          )
          .having((state) => state.feedback?.isError, 'isError', false),
    ],
  );

  blocTest<ListingBloc, ListingState>(
    'shows the repository message when a delete is refused',
    build: () {
      when(
        () => repository.deleteListing(
          businessId: testBusinessId,
          listingId: listing.id,
        ),
      ).thenThrow(const ListingFailure('Customers are still waiting'));
      return ListingBloc(listingRepository: repository);
    },
    seed: () => ListingState(
      status: ListingsStatus.success,
      businessId: testBusinessId,
      listings: [listing],
    ),
    act: (bloc) => bloc.add(ListingDeleteRequested(listing.id)),
    skip: 1,
    expect: () => [
      isA<ListingState>()
          .having(
            (state) => state.feedback?.message,
            'message',
            'Customers are still waiting',
          )
          .having((state) => state.feedback?.isError, 'isError', true),
    ],
  );
}
