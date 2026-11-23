import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/features/orders/domain/entities/order_details.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/presentation/widgets/order_detail_body.dart';
import 'package:sokosafi/router/app_routes.dart';

import '../../../../helpers/order_fixtures.dart';

void main() {
  Future<void> pumpBody(WidgetTester tester, OrderDetails details) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              Scaffold(body: OrderDetailBody(details: details)),
        ),
        GoRoute(
          path: AppRoutes.rateOrder,
          builder: (context, state) =>
              Text('Rating ${state.pathParameters['orderId']}'),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('a collected order opens the rating screen', (tester) async {
    await pumpBody(tester, orderDetails(status: OrderStatus.collected));

    await tester.scrollUntilVisible(find.text('Rate your pickup'), 200);
    await tester.tap(find.text('Rate your pickup'));
    await tester.pumpAndSettle();

    expect(find.text('Rating order-1'), findsOneWidget);
  });

  testWidgets('a paid order cannot be rated yet', (tester) async {
    await pumpBody(tester, orderDetails());

    expect(find.text('Rate your pickup'), findsNothing);
  });
}
