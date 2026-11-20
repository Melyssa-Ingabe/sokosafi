import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/reviews/domain/entities/review_tag.dart';
import 'package:sokosafi/features/reviews/domain/entities/review_target.dart';
import 'package:sokosafi/features/reviews/domain/failures/review_failure.dart';
import 'package:sokosafi/features/reviews/domain/repositories/review_repository.dart';
import 'package:sokosafi/features/reviews/presentation/bloc/rate_experience_cubit.dart';

class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late MockReviewRepository repository;
  const target = ReviewTarget(
    orderId: 'order-1',
    businessId: 'bakery',
    businessName: 'Boulangerie de Kigali',
    businessPhotoUrl: '',
    collectedAt: null,
    alreadyReviewed: false,
  );
  const readyState = RateExperienceState(
    status: RateExperienceStatus.ready,
    target: target,
  );

  RateExperienceCubit buildCubit() => RateExperienceCubit(
    repository: repository,
    orderId: 'order-1',
    customerId: 'customer-1',
  );

  void whenLoading(Future<ReviewTarget> Function() answer) {
    when(
      () => repository.loadTarget(orderId: 'order-1', customerId: 'customer-1'),
    ).thenAnswer((_) => answer());
  }

  setUpAll(() => registerFallbackValue(target));
  setUp(() => repository = MockReviewRepository());

  group('composeReviewComment', () {
    test('tags go before the note', () {
      expect(
        composeReviewComment({
          ReviewTag.friendlyStaff,
          ReviewTag.freshFood,
        }, ' Lovely bread '),
        'Fresh food, Friendly staff. Lovely bread',
      );
    });

    test('works with only tags or only a note', () {
      expect(composeReviewComment({ReviewTag.generousBag}, ''), 'Generous bag');
      expect(composeReviewComment({}, 'Very kind'), 'Very kind');
    });
  });

  group('load', () {
    blocTest<RateExperienceCubit, RateExperienceState>(
      'a collected order opens the form',
      setUp: () => whenLoading(() async => target),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [const RateExperienceState(), readyState],
    );

    blocTest<RateExperienceCubit, RateExperienceState>(
      'an order that was already rated says so',
      setUp: () => whenLoading(
        () async => const ReviewTarget(
          orderId: 'order-1',
          businessId: 'bakery',
          businessName: 'Boulangerie de Kigali',
          businessPhotoUrl: '',
          collectedAt: null,
          alreadyReviewed: true,
        ),
      ),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      verify: (cubit) =>
          expect(cubit.state.status, RateExperienceStatus.alreadyRated),
    );

    blocTest<RateExperienceCubit, RateExperienceState>(
      'an order that cannot be rated shows the reason',
      setUp: () => whenLoading(
        () => Future.error(
          const ReviewFailure(
            'You can rate this order once you have picked it up',
          ),
        ),
      ),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const RateExperienceState(),
        const RateExperienceState(
          status: RateExperienceStatus.failure,
          errorMessage: 'You can rate this order once you have picked it up',
        ),
      ],
    );
  });

  group('choosing', () {
    blocTest<RateExperienceCubit, RateExperienceState>(
      'stars are kept between 1 and 5 and clear the missing-rating message',
      build: buildCubit,
      seed: () => const RateExperienceState(
        status: RateExperienceStatus.ready,
        target: target,
        ratingMissing: true,
      ),
      act: (cubit) => cubit.rate(9),
      verify: (cubit) {
        expect(cubit.state.rating, 5);
        expect(cubit.state.ratingMissing, isFalse);
        expect(cubit.state.ratingLabel, 'Perfect experience!');
      },
    );

    blocTest<RateExperienceCubit, RateExperienceState>(
      'tapping a tag twice removes it again',
      build: buildCubit,
      seed: () => readyState,
      act: (cubit) => cubit
        ..toggleTag(ReviewTag.quickHandoff)
        ..toggleTag(ReviewTag.freshFood)
        ..toggleTag(ReviewTag.quickHandoff),
      verify: (cubit) => expect(cubit.state.tags, {ReviewTag.freshFood}),
    );

    blocTest<RateExperienceCubit, RateExperienceState>(
      'the typed note is kept',
      build: buildCubit,
      seed: () => readyState,
      act: (cubit) => cubit.noteChanged('Lovely bread'),
      verify: (cubit) => expect(cubit.state.note, 'Lovely bread'),
    );

    test('each star count has its own label', () {
      expect(const RateExperienceState().ratingLabel, 'Tap a star to rate');
      expect(const RateExperienceState(rating: 1).ratingLabel, 'Poor');
      expect(const RateExperienceState(rating: 2).ratingLabel, 'Not great');
      expect(const RateExperienceState(rating: 3).ratingLabel, 'Okay');
      expect(const RateExperienceState(rating: 4).ratingLabel, 'Good');
    });
  });

  group('submit', () {
    blocTest<RateExperienceCubit, RateExperienceState>(
      'submitting without stars asks for a rating and saves nothing',
      build: buildCubit,
      seed: () => readyState,
      act: (cubit) => cubit.submit(),
      verify: (cubit) {
        expect(cubit.state.ratingMissing, isTrue);
        verifyNever(
          () => repository.submitReview(
            target: any(named: 'target'),
            customerId: any(named: 'customerId'),
            rating: any(named: 'rating'),
            comment: any(named: 'comment'),
          ),
        );
      },
    );

    blocTest<RateExperienceCubit, RateExperienceState>(
      'a rated review is saved and ends in submitted',
      setUp: () => when(
        () => repository.submitReview(
          target: target,
          customerId: 'customer-1',
          rating: 4,
          comment: 'Quick handoff',
        ),
      ).thenAnswer((_) async {}),
      build: buildCubit,
      seed: () => readyState,
      act: (cubit) async {
        cubit.rate(4);
        cubit.toggleTag(ReviewTag.quickHandoff);
        await cubit.submit();
      },
      verify: (cubit) =>
          expect(cubit.state.status, RateExperienceStatus.submitted),
    );

    blocTest<RateExperienceCubit, RateExperienceState>(
      'a failed save returns to the form with the reason',
      setUp: () =>
          when(
            () => repository.submitReview(
              target: any(named: 'target'),
              customerId: any(named: 'customerId'),
              rating: any(named: 'rating'),
              comment: any(named: 'comment'),
            ),
          ).thenAnswer(
            (_) => Future.error(
              const ReviewFailure('You have already rated this pickup'),
            ),
          ),
      build: buildCubit,
      seed: () => readyState,
      act: (cubit) async {
        cubit.rate(5);
        await cubit.submit();
      },
      verify: (cubit) {
        expect(cubit.state.status, RateExperienceStatus.ready);
        expect(cubit.state.submitError, 'You have already rated this pickup');
      },
    );

    blocTest<RateExperienceCubit, RateExperienceState>(
      'nothing happens while the order is still loading',
      build: buildCubit,
      act: (cubit) => cubit.submit(),
      expect: () => <RateExperienceState>[],
    );
  });
}
