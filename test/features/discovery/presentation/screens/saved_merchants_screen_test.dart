import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/discovery/domain/entities/saved_merchant.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/saved_merchants_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/screens/saved_merchants_screen.dart';

import '../../discovery_test_data.dart';

class MockSavedMerchantsCubit extends MockCubit<SavedMerchantsState>
    implements SavedMerchantsCubit {}

class MockDiscoveryRepository extends Mock implements DiscoveryRepository {}

void main() {
  late MockSavedMerchantsCubit cubit;

  final bakery = buildBusiness(id: 'bakery', name: 'Boulangerie de Kigali');
  final cafe = buildBusiness(id: 'cafe', name: 'Cafe Kigali Bistro');

  setUpAll(() => registerFallbackValue(bakery));

  setUp(() {
    cubit = MockSavedMerchantsCubit();
    when(() => cubit.toggle(any())).thenAnswer((_) async {});
  });

  Future<void> pumpSaved(WidgetTester tester, {Size? screenSize}) async {
    if (screenSize != null) {
      tester.view.physicalSize = screenSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SavedMerchantsCubit>.value(
          value: cubit,
          child: SavedMerchantsScreen(
            discoveryRepository: MockDiscoveryRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  SavedMerchantsState savedState() => SavedMerchantsState(
    status: SavedMerchantsStatus.ready,
    merchants: [
      SavedMerchant(business: bakery, savedAt: feedNow),
      SavedMerchant(business: cafe, savedAt: feedNow),
    ],
  );

  testWidgets('lists every saved shop with a count', (tester) async {
    when(() => cubit.state).thenReturn(savedState());

    await pumpSaved(tester);

    expect(find.text('2 favourite spots'), findsOneWidget);
    expect(find.text('Boulangerie de Kigali'), findsOneWidget);
    expect(find.text('Cafe Kigali Bistro'), findsOneWidget);
  });

  testWidgets('explains how to save a shop when the list is empty', (
    tester,
  ) async {
    when(
      () => cubit.state,
    ).thenReturn(const SavedMerchantsState(status: SavedMerchantsStatus.ready));

    await pumpSaved(tester);

    expect(find.text('No saved shops yet'), findsOneWidget);
  });

  testWidgets('swiping a card left removes the shop', (tester) async {
    when(() => cubit.state).thenReturn(savedState());

    await pumpSaved(tester);
    await tester.drag(
      find.text('Boulangerie de Kigali'),
      const Offset(-600, 0),
    );
    await tester.pumpAndSettle();

    verify(() => cubit.toggle(bakery)).called(1);
  });

  testWidgets('tapping the heart removes the shop', (tester) async {
    when(() => cubit.state).thenReturn(savedState());

    await pumpSaved(tester);
    await tester.tap(find.byTooltip('Remove Boulangerie de Kigali from saved'));

    verify(() => cubit.toggle(bakery)).called(1);
  });

  testWidgets('lays out without overflow on a small phone', (tester) async {
    when(() => cubit.state).thenReturn(savedState());

    await pumpSaved(tester, screenSize: const Size(320, 568));

    expect(tester.takeException(), isNull);
  });
}
