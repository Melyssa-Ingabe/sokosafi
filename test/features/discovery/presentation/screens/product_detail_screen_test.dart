import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/core/constants/app_icons.dart';
import 'package:sokosafi/features/discovery/domain/entities/saved_merchant.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/product_detail_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/saved_merchants_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/screens/product_detail_screen.dart';

import '../../discovery_test_data.dart';

class MockProductDetailCubit extends MockCubit<ProductDetailState>
    implements ProductDetailCubit {}

class MockSavedMerchantsCubit extends MockCubit<SavedMerchantsState>
    implements SavedMerchantsCubit {}

void main() {
  late MockProductDetailCubit cubit;
  late MockSavedMerchantsCubit savedMerchants;

  setUpAll(() => registerFallbackValue(buildBusiness()));

  setUp(() {
    cubit = MockProductDetailCubit();
    savedMerchants = MockSavedMerchantsCubit();
    when(
      () => savedMerchants.state,
    ).thenReturn(const SavedMerchantsState(status: SavedMerchantsStatus.ready));
    when(() => savedMerchants.toggle(any())).thenAnswer((_) async {});
  });

  Future<void> pumpDetail(WidgetTester tester, {Size? screenSize}) async {
    if (screenSize != null) {
      tester.view.physicalSize = screenSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ProductDetailCubit>.value(value: cubit),
            BlocProvider<SavedMerchantsCubit>.value(value: savedMerchants),
          ],
          child: const ProductDetailScreen(),
        ),
      ),
    );
  }

  ProductDetailState readyWith({bool acceptingOrders = true}) {
    // Pick-up time is a few hours from the real clock, since the screen
    // checks availability against "now".
    final item = buildFeedItem(
      pickupIn: DateTime.now().difference(feedNow) + const Duration(hours: 3),
      business: buildBusiness(acceptingOrders: acceptingOrders),
    );
    return ProductDetailState(
      status: ProductDetailStatus.ready,
      item: item,
      quantity: 3,
    );
  }

  testWidgets('shows the listing, the shop and the running total', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(readyWith());

    await pumpDetail(tester);

    expect(find.text('Listing listing-1'), findsOneWidget);
    expect(find.text('5 left'), findsOneWidget);
    expect(find.text('KG 5 Ave, Kacyiru'), findsOneWidget);
    expect(find.text('Total (3 items)'), findsOneWidget);
    expect(find.text('4,500 RWF'), findsOneWidget);
    expect(find.text('Reserve'), findsOneWidget);
  });

  testWidgets('the heart saves the shop', (tester) async {
    when(() => cubit.state).thenReturn(readyWith());

    await pumpDetail(tester);
    await tester.tap(find.byTooltip('Save Boulangerie de Kigali'));

    verify(() => savedMerchants.toggle(buildBusiness())).called(1);
  });

  testWidgets('the heart is filled when the shop is already saved', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(readyWith());
    when(() => savedMerchants.state).thenReturn(
      SavedMerchantsState(
        status: SavedMerchantsStatus.ready,
        merchants: [SavedMerchant(business: buildBusiness(), savedAt: feedNow)],
      ),
    );

    await pumpDetail(tester);

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is HugeIcon && widget.icon == AppIcons.favouriteFilled,
      ),
      findsOneWidget,
    );
    expect(
      find.byTooltip('Remove Boulangerie de Kigali from saved'),
      findsOneWidget,
    );
  });

  testWidgets('turns Reserve off when the shop stops taking orders', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(readyWith(acceptingOrders: false));

    await pumpDetail(tester);

    expect(find.text('Not available'), findsOneWidget);
    expect(find.text('Reserve'), findsNothing);
  });

  testWidgets('offers a way back when the listing is gone', (tester) async {
    when(() => cubit.state).thenReturn(
      const ProductDetailState(
        status: ProductDetailStatus.failure,
        errorMessage: 'This food is no longer listed',
      ),
    );

    await pumpDetail(tester);

    expect(find.text('This food is no longer listed'), findsOneWidget);
    expect(find.text('Back to the feed'), findsOneWidget);
  });

  for (final (name, size) in [
    ('a small phone', const Size(320, 568)),
    ('landscape', const Size(800, 360)),
  ]) {
    testWidgets('lays out without overflow on $name', (tester) async {
      when(() => cubit.state).thenReturn(readyWith());

      await pumpDetail(tester, screenSize: size);

      expect(tester.takeException(), isNull);
    });
  }
}
