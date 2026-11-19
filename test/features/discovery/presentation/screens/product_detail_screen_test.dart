import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/product_detail_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/screens/product_detail_screen.dart';

import '../../discovery_test_data.dart';

class MockProductDetailCubit extends MockCubit<ProductDetailState>
    implements ProductDetailCubit {}

void main() {
  late MockProductDetailCubit cubit;

  setUp(() => cubit = MockProductDetailCubit());

  Future<void> pumpDetail(WidgetTester tester, {Size? screenSize}) async {
    if (screenSize != null) {
      tester.view.physicalSize = screenSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductDetailCubit>.value(
          value: cubit,
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
