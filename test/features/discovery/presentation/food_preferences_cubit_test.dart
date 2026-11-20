import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/repositories/food_preferences_repository.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/food_preferences_cubit.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

class MockFoodPreferencesRepository extends Mock
    implements FoodPreferencesRepository {}

void main() {
  late MockFoodPreferencesRepository repository;

  FoodPreferencesCubit buildCubit({List<String> current = const ['bakery']}) =>
      FoodPreferencesCubit(
        repository: repository,
        uid: 'nelly',
        current: current,
      );

  setUp(() {
    repository = MockFoodPreferencesRepository();
    when(
      () => repository.save(
        uid: any(named: 'uid'),
        categories: any(named: 'categories'),
      ),
    ).thenAnswer((_) async {});
  });

  test('starts with what is on the profile and nothing to save', () {
    final state = buildCubit().state;

    expect(state.selected, {ListingCategory.bakery});
    expect(state.hasChanges, isFalse);
  });

  test('skips names it does not know instead of guessing', () {
    final state = buildCubit(current: ['bakery', 'sushi']).state;

    expect(state.selected, {ListingCategory.bakery});
  });

  blocTest<FoodPreferencesCubit, FoodPreferencesState>(
    'tapping a category ticks it, tapping again unticks it',
    build: buildCubit,
    act: (cubit) => cubit
      ..toggle(ListingCategory.cafe)
      ..toggle(ListingCategory.bakery),
    verify: (cubit) {
      expect(cubit.state.selected, {ListingCategory.cafe});
      expect(cubit.state.hasChanges, isTrue);
    },
  );

  blocTest<FoodPreferencesCubit, FoodPreferencesState>(
    'saves the ticked categories for the signed-in customer',
    build: buildCubit,
    act: (cubit) async {
      cubit.toggle(ListingCategory.meals);
      await cubit.save();
    },
    verify: (cubit) {
      verify(
        () => repository.save(
          uid: 'nelly',
          categories: {ListingCategory.bakery, ListingCategory.meals},
        ),
      ).called(1);
      expect(cubit.state.status, FoodPreferencesStatus.saved);
      expect(cubit.state.hasChanges, isFalse);
    },
  );

  blocTest<FoodPreferencesCubit, FoodPreferencesState>(
    'does not write when nothing changed',
    build: buildCubit,
    act: (cubit) => cubit.save(),
    expect: () => <FoodPreferencesState>[],
    verify: (_) => verifyNever(
      () => repository.save(
        uid: any(named: 'uid'),
        categories: any(named: 'categories'),
      ),
    ),
  );

  blocTest<FoodPreferencesCubit, FoodPreferencesState>(
    'keeps the choice and explains when saving fails',
    setUp: () => when(
      () => repository.save(
        uid: any(named: 'uid'),
        categories: any(named: 'categories'),
      ),
    ).thenThrow(const DiscoveryFailure('You seem to be offline')),
    build: buildCubit,
    act: (cubit) async {
      cubit.toggle(ListingCategory.cafe);
      await cubit.save();
    },
    verify: (cubit) {
      expect(cubit.state.status, FoodPreferencesStatus.failure);
      expect(cubit.state.errorMessage, 'You seem to be offline');
      expect(cubit.state.hasChanges, isTrue);
    },
  );
}
