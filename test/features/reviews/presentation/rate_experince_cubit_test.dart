import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/reviews/domain/entities/review_tag.dart';
import 'package:sokosafi/features/reviews/domain/entities/review_target.dart';
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

  RateExperienceCubit buildCubit() => RateExperienceCubit(
    repository: repository,
    orderId: 'order-1',
    customerId: 'customer-1',
  );

  setUpAll(() => registerFallbackValue(target));
  setUp(() => repository = MockReviewRepository());

  test('tags go before the note in the saved comment', () {
    expect(
      composeReviewComment({
        ReviewTag.friendlyStaff,
        ReviewTag.freshFood,
      }, ' Lovely bread '),
      'Fresh food, Friendly staff. Lovely bread',
    );
  });

  blocTest<RateExperienceCubit, RateExperienceState>(
    'submitting without stars asks for a rating and saves nothing',
    build: buildCubit,
    seed: () => const RateExperienceState(
      status: RateExperienceStatus.ready,
      target: target,
    ),
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
    seed: () => const RateExperienceState(
      status: RateExperienceStatus.ready,
      target: target,
    ),
    act: (cubit) async {
      cubit.rate(4);
      cubit.toggleTag(ReviewTag.quickHandoff);
      await cubit.submit();
    },
    verify: (cubit) =>
        expect(cubit.state.status, RateExperienceStatus.submitted),
  );
}
