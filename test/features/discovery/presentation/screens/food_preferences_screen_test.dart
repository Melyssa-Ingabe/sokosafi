import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/food_preferences_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/screens/food_preferences_screen.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

class MockFoodPreferencesCubit extends MockCubit<FoodPreferencesState>
    implements FoodPreferencesCubit {}

void main() {
  late MockFoodPreferencesCubit cubit;

  setUp(() {
    cubit = MockFoodPreferencesCubit();
    when(() => cubit.save()).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(WidgetTester tester, {Size? screenSize}) async {
    if (screenSize != null) {
      tester.view.physicalSize = screenSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FoodPreferencesCubit>.value(
          value: cubit,
          child: const FoodPreferencesScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  FilledButton saveButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byType(FilledButton));

  testWidgets('shows every category and how many are picked', (tester) async {
    when(() => cubit.state).thenReturn(
      const FoodPreferencesState(
        selected: {ListingCategory.bakery, ListingCategory.cafe},
        saved: {ListingCategory.bakery, ListingCategory.cafe},
      ),
    );

    await pumpScreen(tester);

    for (final category in ListingCategory.values) {
      expect(find.text(category.label), findsOneWidget);
    }
    expect(find.text('2 selected'), findsOneWidget);
  });

  testWidgets('tapping a tile toggles that category', (tester) async {
    when(() => cubit.state).thenReturn(const FoodPreferencesState());

    await pumpScreen(tester);
    await tester.tap(find.text('Grocery'));

    verify(() => cubit.toggle(ListingCategory.grocery)).called(1);
  });

  testWidgets('save is off until something changes', (tester) async {
    when(() => cubit.state).thenReturn(
      const FoodPreferencesState(
        selected: {ListingCategory.meals},
        saved: {ListingCategory.meals},
      ),
    );

    await pumpScreen(tester);

    expect(saveButton(tester).onPressed, isNull);
  });

  testWidgets('saves once the choice has changed', (tester) async {
    when(
      () => cubit.state,
    ).thenReturn(const FoodPreferencesState(selected: {ListingCategory.meals}));

    await pumpScreen(tester);
    await tester.tap(find.text('Save preferences'));

    verify(() => cubit.save()).called(1);
  });

  testWidgets('explains when saving fails', (tester) async {
    whenListen(
      cubit,
      Stream.value(
        const FoodPreferencesState(
          status: FoodPreferencesStatus.failure,
          selected: {ListingCategory.meals},
          errorMessage: 'You seem to be offline',
        ),
      ),
      initialState: const FoodPreferencesState(
        selected: {ListingCategory.meals},
      ),
    );

    await pumpScreen(tester);
    await tester.pump();

    expect(find.text('You seem to be offline'), findsOneWidget);
  });

  testWidgets('lays out without overflow on a small phone', (tester) async {
    when(() => cubit.state).thenReturn(const FoodPreferencesState());

    await pumpScreen(tester, screenSize: const Size(320, 568));

    expect(tester.takeException(), isNull);
  });
}
