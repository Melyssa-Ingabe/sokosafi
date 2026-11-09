import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_input.dart';
import 'package:sokosafi/features/listings/domain/failures/listing_failure.dart';
import 'package:sokosafi/features/listings/domain/repositories/listing_repository.dart';
import 'package:sokosafi/features/listings/presentation/bloc/listing_form_cubit.dart';

import '../../listing_test_data.dart';

class MockListingRepository extends Mock implements ListingRepository {}

void main() {
  late MockListingRepository repository;

  setUpAll(() {
    registerFallbackValue(buildTestInput());
  });

  setUp(() {
    repository = MockListingRepository();
  });

  ListingFormCubit buildCubit({bool editing = false}) {
    return ListingFormCubit(
      listingRepository: repository,
      businessId: testBusinessId,
      initialListing: editing ? buildTestListing() : null,
      clock: () => testNow,
    );
  }

  Future<void> submitValid(ListingFormCubit cubit, {String discount = '600'}) {
    return cubit.submit(
      title: 'Fresh artisan breads',
      description: 'Baguettes and sourdough from this morning',
      originalPrice: '1000',
      discountPrice: discount,
      instructions: 'Side entrance',
    );
  }

  test('a new form starts with a pick-up time two hours from now', () {
    final cubit = buildCubit();
    expect(cubit.state.pickupBy, testNow.add(const Duration(hours: 2)));
    expect(cubit.state.quantity, 1);
    expect(cubit.state.isEditing, isFalse);
  });

  test('an edit form is prefilled from the listing', () {
    final cubit = buildCubit(editing: true);
    expect(cubit.state.isEditing, isTrue);
    expect(cubit.state.quantity, 20);
    expect(cubit.state.category, ListingCategory.bakery);
  });

  blocTest<ListingFormCubit, ListingFormState>(
    'quantity never goes below 1',
    build: buildCubit,
    act: (cubit) => cubit.quantityDecremented(),
    verify: (cubit) => expect(cubit.state.quantity, 1),
  );

  blocTest<ListingFormCubit, ListingFormState>(
    'refuses to save when the discount is higher than the original price',
    build: buildCubit,
    act: (cubit) => submitValid(cubit, discount: '1500'),
    expect: () => [
      isA<ListingFormState>()
          .having((state) => state.status, 'status', ListingFormStatus.editing)
          .having((state) => state.feedback?.isError, 'isError', true),
    ],
    verify: (_) => verifyNever(
      () => repository.createListing(
        businessId: any(named: 'businessId'),
        input: any(named: 'input'),
      ),
    ),
  );

  blocTest<ListingFormCubit, ListingFormState>(
    'refuses to save when the pick-up time has already passed',
    build: buildCubit,
    act: (cubit) {
      cubit.pickupByChanged(testNow.subtract(const Duration(minutes: 5)));
      return submitValid(cubit);
    },
    skip: 1,
    expect: () => [
      isA<ListingFormState>().having(
        (state) => state.pickupByError,
        'pickupByError',
        'Pick-up time must be in the future',
      ),
    ],
  );

  blocTest<ListingFormCubit, ListingFormState>(
    'creates the listing and confirms with "Listing published"',
    build: () {
      when(
        () => repository.createListing(
          businessId: any(named: 'businessId'),
          input: any(named: 'input'),
        ),
      ).thenAnswer((_) async => 'new-listing');
      return buildCubit();
    },
    act: submitValid,
    expect: () => [
      isA<ListingFormState>().having(
        (state) => state.status,
        'status',
        ListingFormStatus.submitting,
      ),
      isA<ListingFormState>()
          .having((state) => state.status, 'status', ListingFormStatus.success)
          .having(
            (state) => state.feedback?.message,
            'message',
            'Listing published',
          ),
    ],
    verify: (_) {
      final saved =
          verify(
                () => repository.createListing(
                  businessId: testBusinessId,
                  input: captureAny(named: 'input'),
                ),
              ).captured.single
              as ListingInput;
      expect(saved.originalPrice, 1000);
      expect(saved.discountPrice, 600);
    },
  );

  blocTest<ListingFormCubit, ListingFormState>(
    'updates an existing listing and confirms with "Listing updated"',
    build: () {
      when(
        () => repository.updateListing(
          listingId: any(named: 'listingId'),
          input: any(named: 'input'),
        ),
      ).thenAnswer((_) async {});
      return buildCubit(editing: true);
    },
    act: submitValid,
    skip: 1,
    expect: () => [
      isA<ListingFormState>().having(
        (state) => state.feedback?.message,
        'message',
        'Listing updated',
      ),
    ],
    verify: (_) => verify(
      () => repository.updateListing(
        listingId: 'listing-1',
        input: any(named: 'input'),
      ),
    ).called(1),
  );

  blocTest<ListingFormCubit, ListingFormState>(
    'goes back to editing with a polite message when saving fails',
    build: () {
      when(
        () => repository.createListing(
          businessId: any(named: 'businessId'),
          input: any(named: 'input'),
        ),
      ).thenThrow(const ListingFailure('You seem to be offline'));
      return buildCubit();
    },
    act: submitValid,
    skip: 1,
    expect: () => [
      isA<ListingFormState>()
          .having((state) => state.status, 'status', ListingFormStatus.editing)
          .having(
            (state) => state.feedback?.message,
            'message',
            'You seem to be offline',
          ),
    ],
  );
}
