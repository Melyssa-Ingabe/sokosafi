import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/orders/domain/entities/order_details.dart';
import 'package:sokosafi/features/orders/domain/entities/order_stats.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/domain/failures/orders_failure.dart';
import 'package:sokosafi/features/orders/domain/repositories/orders_repository.dart';
import 'package:sokosafi/features/orders/presentation/cubit/my_orders_cubit.dart';

import '../../../helpers/order_fixtures.dart';

class MockOrdersRepository extends Mock implements OrdersRepository {}

void main() {
  late MockOrdersRepository repository;
  final active = orderDetails(id: 'active');
  final collected = orderDetails(
    id: 'collected',
    status: OrderStatus.collected,
  );
  final cancelled = orderDetails(
    id: 'cancelled',
    status: OrderStatus.cancelled,
  );

  MyOrdersCubit buildCubit() =>
      MyOrdersCubit(repository: repository, customerId: 'customer-1');

  setUp(() => repository = MockOrdersRepository());

  blocTest<MyOrdersCubit, MyOrdersState>(
    'splits streamed orders into active and past',
    setUp: () =>
        when(() => repository.watchCustomerOrders('customer-1'))
            .thenAnswer((_) => Stream.value([active, collected, cancelled])),
    build: buildCubit,
    act: (cubit) => cubit.watch(),
    skip: 1,
    verify: (cubit) {
      expect(cubit.state.status, MyOrdersStatus.ready);
      expect(cubit.state.activeOrders, [active]);
      expect(cubit.state.pastOrders, [collected, cancelled]);
    },
  );

  blocTest<MyOrdersCubit, MyOrdersState>(
    'shows the error when orders cannot load',
    setUp: () => when(() => repository.watchCustomerOrders('customer-1'))
        .thenAnswer(
          (_) => Stream<List<OrderDetails>>.error(
            const OrdersFailure('You seem to be offline'),
          ),
        ),
    build: buildCubit,
    act: (cubit) => cubit.watch(),
    expect: () => [
      const MyOrdersState(),
      const MyOrdersState(
        status: MyOrdersStatus.failure,
        errorMessage: 'You seem to be offline',
      ),
    ],
  );

  group('newest active order', () {
    final older = orderDetails(
      id: 'older',
      createdAt: fixtureNow.subtract(const Duration(hours: 1)),
    );

    blocTest<MyOrdersCubit, MyOrdersState>(
      'opens on the first load',
      setUp: () =>
          when(() => repository.watchCustomerOrders('customer-1'))
              .thenAnswer((_) => Stream.value([older, active, collected])),
      build: buildCubit,
      act: (cubit) => cubit.watch(),
      verify: (cubit) => expect(cubit.state.expandedOrderId, 'active'),
    );

    blocTest<MyOrdersCubit, MyOrdersState>(
      'stays closed after the customer closes it and the list updates',
      setUp: () => when(() => repository.watchCustomerOrders('customer-1'))
          .thenAnswer(
            (_) => Stream.fromIterable([
              [older, active],
              [older, active, collected],
            ]),
          ),
      build: buildCubit,
      act: (cubit) async {
        cubit.watch();
        await Future<void>.delayed(Duration.zero);
        cubit.toggleExpanded('active');
      },
      wait: const Duration(milliseconds: 10),
      verify: (cubit) {
        expect(cubit.state.orders, hasLength(3));
        expect(cubit.state.expandedOrderId, isNull);
      },
    );

    blocTest<MyOrdersCubit, MyOrdersState>(
      'opens again when the customer comes back to the Active tab',
      build: buildCubit,
      seed: () => MyOrdersState(
        status: MyOrdersStatus.ready,
        orders: [older, active],
        tab: OrdersTab.past,
      ),
      act: (cubit) => cubit.selectTab(OrdersTab.active),
      verify: (cubit) => expect(cubit.state.expandedOrderId, 'active'),
    );
  });

  blocTest<MyOrdersCubit, MyOrdersState>(
    'switching tabs collapses the open order',
    build: buildCubit,
    act: (cubit) => cubit
      ..toggleExpanded('active')
      ..selectTab(OrdersTab.past),
    expect: () => [
      const MyOrdersState(expandedOrderId: 'active'),
      const MyOrdersState(tab: OrdersTab.past),
    ],
  );

  blocTest<MyOrdersCubit, MyOrdersState>(
    'reports a failed cancel without losing the list',
    setUp: () => when(() => repository.cancelOrder('active'))
        .thenThrow(const OrdersFailure('Only active orders can be cancelled')),
    build: buildCubit,
    seed: () => MyOrdersState(status: MyOrdersStatus.ready, orders: [active]),
    act: (cubit) => cubit.cancelOrder('active'),
    verify: (cubit) {
      expect(cubit.state.orders, [active]);
      expect(cubit.state.cancellingOrderId, isNull);
      expect(cubit.state.feedback?.isError, isTrue);
    },
  );

  test('stats ignore cancelled orders and count collected meals', () {
    final stats = OrderStats.from([active, collected, cancelled]);

    expect(stats.orderCount, 2);
    expect(stats.amountSaved, 1600);
    expect(stats.mealsRescued, 2);
  });
}
