import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';
import 'package:sokosafi/features/business_orders/domain/repositories/business_orders_repository.dart';
import 'package:sokosafi/features/business_orders/presentation/bloc/business_orders_cubit.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';

import '../../../helpers/order_fixtures.dart';

class MockBusinessOrdersRepository extends Mock
    implements BusinessOrdersRepository {}

BusinessOrder businessOrder(String id, OrderStatus status) {
  return BusinessOrder(
    order: orderDetails(id: id, status: status).order,
    listingTitle: 'Fresh breads',
  );
}

void main() {
  late MockBusinessOrdersRepository repository;
  final paid = businessOrder('paid', OrderStatus.paid);
  final collected = businessOrder('collected', OrderStatus.collected);
  final cancelled = businessOrder('cancelled', OrderStatus.cancelled);

  BusinessOrdersCubit buildCubit() =>
      BusinessOrdersCubit(repository: repository, businessId: 'bakery');

  setUp(() => repository = MockBusinessOrdersRepository());

  blocTest<BusinessOrdersCubit, BusinessOrdersState>(
    'splits streamed orders into incoming, completed and cancelled',
    setUp: () =>
        when(() => repository.watchOrders('bakery'))
            .thenAnswer((_) => Stream.value([paid, collected, cancelled])),
    build: buildCubit,
    act: (cubit) => cubit.watch(),
    skip: 1,
    verify: (cubit) {
      expect(cubit.state.status, BusinessOrdersStatus.ready);
      expect(cubit.state.ordersFor(BusinessOrdersTab.incoming), [paid]);
      expect(cubit.state.ordersFor(BusinessOrdersTab.completed), [collected]);
      expect(cubit.state.ordersFor(BusinessOrdersTab.cancelled), [cancelled]);
    },
  );

  blocTest<BusinessOrdersCubit, BusinessOrdersState>(
    'shows a polite message when orders cannot load',
    setUp: () => when(() => repository.watchOrders('bakery')).thenAnswer(
      (_) => Stream<List<BusinessOrder>>.error(
        const BusinessOrdersFailure('You seem to be offline'),
      ),
    ),
    build: buildCubit,
    act: (cubit) => cubit.watch(),
    expect: () => [
      const BusinessOrdersState(),
      const BusinessOrdersState(
        status: BusinessOrdersStatus.failure,
        errorMessage: 'You seem to be offline',
      ),
    ],
  );

  blocTest<BusinessOrdersCubit, BusinessOrdersState>(
    'switching tabs changes the visible orders',
    build: buildCubit,
    seed: () => BusinessOrdersState(
      status: BusinessOrdersStatus.ready,
      orders: [paid, collected, cancelled],
    ),
    act: (cubit) => cubit.selectTab(BusinessOrdersTab.completed),
    verify: (cubit) => expect(cubit.state.visibleOrders, [collected]),
  );
}
