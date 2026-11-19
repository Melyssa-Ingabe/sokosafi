import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/discovery/domain/entities/search_filter.dart';
import 'package:sokosafi/features/discovery/domain/search_results.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/search_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/screens/search_screen.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

import '../../discovery_test_data.dart';

class MockSearchCubit extends MockCubit<SearchState> implements SearchCubit {}

void main() {
  late MockSearchCubit cubit;

  setUp(() => cubit = MockSearchCubit());

  Future<void> pumpSearch(WidgetTester tester, {Size? screenSize}) async {
    if (screenSize != null) {
      tester.view.physicalSize = screenSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SearchCubit>.value(
          value: cubit,
          child: const SearchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  SearchState withResults() => SearchState(
    status: SearchStatus.ready,
    availableCount: 1,
    results: [SearchResult(item: buildFeedItem(id: 'bread'), distanceKm: 0.35)],
  );

  testWidgets('shows each result with its shop and distance', (tester) async {
    when(() => cubit.state).thenReturn(withResults());

    await pumpSearch(tester);

    expect(find.text('Boulangerie de Kigali'), findsOneWidget);
    expect(find.text('350 m away'), findsOneWidget);
  });

  testWidgets('sends what is typed to the cubit', (tester) async {
    when(() => cubit.state).thenReturn(withResults());

    await pumpSearch(tester);
    await tester.enterText(find.byType(TextField), 'bread');

    verify(() => cubit.updateQuery('bread')).called(1);
  });

  testWidgets('tapping a category chip filters by it', (tester) async {
    when(() => cubit.state).thenReturn(withResults());

    await pumpSearch(tester);
    await tester.tap(find.text('Grocery'));

    verify(() => cubit.selectCategory(ListingCategory.grocery)).called(1);
  });

  testWidgets('offers to clear the filters when nothing matches', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(
      const SearchState(
        status: SearchStatus.ready,
        filter: SearchFilter(maxPriceRwf: 500),
        availableCount: 3,
      ),
    );

    await pumpSearch(tester);
    await tester.tap(find.text('Clear filters'));

    expect(find.text('No food matches'), findsOneWidget);
    verify(() => cubit.clearFilters()).called(1);
  });

  testWidgets('says nothing is on sale rather than blaming the filters', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(
      const SearchState(
        status: SearchStatus.ready,
        filter: SearchFilter(radiusKm: 5),
        defaultRadiusKm: 5,
      ),
    );

    await pumpSearch(tester);

    expect(find.text('No surplus food right now'), findsOneWidget);
    expect(find.text('Clear filters'), findsNothing);
  });

  testWidgets('lays out without overflow on a small phone', (tester) async {
    when(() => cubit.state).thenReturn(withResults());

    await pumpSearch(tester, screenSize: const Size(320, 568));

    expect(tester.takeException(), isNull);
  });
}
