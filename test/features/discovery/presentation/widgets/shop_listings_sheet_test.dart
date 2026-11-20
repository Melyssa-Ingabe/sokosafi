import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/discovery/domain/failures/discovery_failure.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/shop_listings_sheet.dart';
import 'package:sokosafi/router/app_routes.dart';

import '../../discovery_test_data.dart';

class MockDiscoveryRepository extends Mock implements DiscoveryRepository {}

void main() {
  late MockDiscoveryRepository repository;
  late StreamController<List<FeedItem>> shopItems;
  final shop = buildBusiness();

  // The sheet's cubit uses the real clock, so the food must still be on
  // sale today rather than at the fixed feedNow.
  FeedItem onSaleToday({String id = 'bread', int quantity = 5}) =>
      buildFeedItem(
        id: id,
        quantity: quantity,
        pickupIn: DateTime.now().difference(feedNow) + const Duration(hours: 3),
      );

  setUpAll(() => registerFallbackValue(shop));

  setUp(() {
    repository = MockDiscoveryRepository();
    shopItems = StreamController<List<FeedItem>>.broadcast();
    when(() => repository.watchShopItems(any()))
        .thenAnswer((_) => shopItems.stream);
  });

  tearDown(() => shopItems.close());

  Future<void> openSheet(WidgetTester tester, {Business? business}) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showShopListingsSheet(
                  context,
                  business: business ?? shop,
                  repository: repository,
                ),
                child: const Text('Explore surplus'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.listingDetail,
          builder: (context, state) =>
              Text('Detail of ${state.pathParameters['listingId']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Explore surplus'));
    // The spinner never settles, so wait out the sheet's slide-in instead.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('shows a spinner until the shop loads', (tester) async {
    await openSheet(tester);

    expect(find.text('On sale at Boulangerie de Kigali'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('lists the food on sale with its price and stock', (
    tester,
  ) async {
    await openSheet(tester);
    shopItems.add([onSaleToday(quantity: 4)]);
    await tester.pumpAndSettle();

    expect(find.text('Listing bread'), findsOneWidget);
    expect(find.textContaining('4 left'), findsOneWidget);
    expect(find.text(Formatters.rwf(1500)), findsOneWidget);
  });

  testWidgets('leaves out food that is no longer on sale', (tester) async {
    await openSheet(tester);
    shopItems.add([
      onSaleToday(id: 'bread'),
      onSaleToday(id: 'cake', quantity: 0),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Listing bread'), findsOneWidget);
    expect(find.text('Listing cake'), findsNothing);
  });

  testWidgets('tapping food closes the sheet and opens its detail', (
    tester,
  ) async {
    await openSheet(tester);
    shopItems.add([onSaleToday()]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Listing bread'));
    await tester.pumpAndSettle();

    expect(find.text('Detail of bread'), findsOneWidget);
    expect(find.text('On sale at Boulangerie de Kigali'), findsNothing);
  });

  testWidgets('says so when the shop has nothing on sale', (tester) async {
    await openSheet(tester);
    shopItems.add([]);
    await tester.pumpAndSettle();

    expect(find.text('Nothing on sale right now'), findsOneWidget);
  });

  testWidgets('explains a failure and tries again', (tester) async {
    await openSheet(tester);
    shopItems.addError(const DiscoveryFailure('You seem to be offline'));
    await tester.pumpAndSettle();

    expect(find.text('We could not load this shop'), findsOneWidget);
    expect(find.text('You seem to be offline'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();

    verify(() => repository.watchShopItems(shop)).called(2);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
