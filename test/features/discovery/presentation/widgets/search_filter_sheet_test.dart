import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/features/discovery/domain/entities/search_filter.dart';
import 'package:sokosafi/features/discovery/domain/search_results.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/search_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/search_filter_sheet.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

import '../../discovery_test_data.dart';

class MockSearchCubit extends MockCubit<SearchState> implements SearchCubit {}

const CustomerLocation _kigali = CustomerLocation(
  latitude: -1.9441,
  longitude: 30.0619,
);

void main() {
  late MockSearchCubit cubit;

  setUp(() => cubit = MockSearchCubit());

  Future<void> openSheet(WidgetTester tester, SearchState state) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SearchCubit>.value(
          value: cubit,
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showSearchFilterSheet(context),
                  child: const Text('Filters'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
  }

  ChoiceChip chip(WidgetTester tester, String label) => tester.widget(
    find.ancestor(of: find.text(label), matching: find.byType(ChoiceChip)),
  );

  testWidgets('a price chip applies straight away', (tester) async {
    await openSheet(
      tester,
      const SearchState(
        status: SearchStatus.ready,
        filter: SearchFilter(radiusKm: 5),
        location: _kigali,
      ),
    );

    await tester.tap(find.text('Up to ${Formatters.rwf(1000)}'));

    verify(() => cubit.applyLimits(maxPriceRwf: 1000, radiusKm: 5)).called(1);
  });

  testWidgets('a distance chip keeps the chosen price', (tester) async {
    await openSheet(
      tester,
      const SearchState(
        status: SearchStatus.ready,
        filter: SearchFilter(maxPriceRwf: 2000),
        location: _kigali,
      ),
    );

    await tester.tap(find.text('Within 3 km'));

    verify(() => cubit.applyLimits(maxPriceRwf: 2000, radiusKm: 3)).called(1);
  });

  testWidgets('"Any" removes the price limit', (tester) async {
    await openSheet(
      tester,
      const SearchState(
        status: SearchStatus.ready,
        filter: SearchFilter(maxPriceRwf: 2000),
        location: _kigali,
      ),
    );

    expect(chip(tester, 'Up to ${Formatters.rwf(2000)}').selected, isTrue);
    await tester.tap(find.text('Any').first);

    verify(() => cubit.applyLimits(radiusKm: null)).called(1);
  });

  testWidgets('distance is off until the phone shares its location', (
    tester,
  ) async {
    await openSheet(tester, const SearchState(status: SearchStatus.ready));

    expect(find.text('Allow location to use this filter'), findsOneWidget);
    expect(chip(tester, 'Within 5 km').onSelected, isNull);
    expect(chip(tester, 'Up to ${Formatters.rwf(500)}').onSelected, isNotNull);
  });

  testWidgets('clear filters is off when nothing is filtered', (tester) async {
    await openSheet(tester, const SearchState(status: SearchStatus.ready));

    final clear = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Clear filters'),
    );
    expect(clear.onPressed, isNull);
  });

  testWidgets('clear filters resets a chosen category', (tester) async {
    await openSheet(
      tester,
      const SearchState(
        status: SearchStatus.ready,
        filter: SearchFilter(category: ListingCategory.bakery),
      ),
    );

    await tester.tap(find.text('Clear filters'));

    verify(() => cubit.clearFilters()).called(1);
  });

  testWidgets('the show button counts the results and closes the sheet', (
    tester,
  ) async {
    await openSheet(
      tester,
      SearchState(
        status: SearchStatus.ready,
        results: [
          SearchResult(item: buildFeedItem(id: 'bread')),
          SearchResult(item: buildFeedItem(id: 'cake')),
        ],
      ),
    );

    await tester.tap(find.text('Show 2'));
    await tester.pumpAndSettle();

    expect(find.byType(SearchFilterSheet), findsNothing);
  });
}
