import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/orders/domain/entities/order_details.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/domain/failures/orders_failure.dart';
import 'package:sokosafi/features/orders/domain/repositories/orders_repository.dart';
import 'package:sokosafi/features/orders/presentation/cubit/order_detail_cubit.dart';

import '../../../helpers/order_fixtures.dart';

class MockOrdersRepository extends Mock implements OrdersRepository {}

void main() {
  late MockOrdersRepository repository;
  final details = orderDetails();

  OrderDetailCubit buildCubit() =>
      OrderDetailCubit(repository: repository, orderId: 'order-1');

  setUp(() => repository = MockOrdersRepository());

  blocTest<OrderDetailCubit, OrderDetailState>(
    'emits ready when the order stream yields data',
    setUp: () => when(() => repository.watchOrder('order-1'))
        .thenAnswer((_) => Stream.value(details)),
    build: buildCubit,
    act: (cubit) => cubit.watch(),
    expect: () => [
      const OrderDetailState.loading(),
      OrderDetailState.ready(details),
    ],
  );

  blocTest<OrderDetailCubit, OrderDetailState>(
    'emits failure when the order stream errors',
    setUp: () => when(() => repository.watchOrder('order-1')).thenAnswer(
      (_) => Stream.error(const OrdersFailure('Not found')),
    ),
    build: buildCubit,
    act: (cubit) => cubit.watch(),
    expect: () => [
      const OrderDetailState.loading(),
      const OrderDetailState.failure('Not found'),
    ],
  );

  blocTest<OrderDetailCubit, OrderDetailState>(
    'cancel sets isCancelling while awaiting the repository',
    setUp: () {
      when(() => repository.watchOrder('order-1'))
          .thenAnswer((_) => Stream.value(details));
      when(() => repository.cancelOrder('order-1'))
          .thenAnswer((_) async {});
    },
    build: buildCubit,
    seed: () => OrderDetailState.ready(details),
    act: (cubit) => cubit.cancel(),
    expect: () => [
      OrderDetailReady(details, isCancelling: true),
    ],
  );

  blocTest<OrderDetailCubit, OrderDetailState>(
    'cancel resets isCancelling and stores error on failure',
    setUp: () {
      when(() => repository.cancelOrder('order-1'))
          .thenThrow(const OrdersFailure('Only active orders can be cancelled'));
    },
    build: buildCubit,
    seed: () => OrderDetailState.ready(details),
    act: (cubit) => cubit.cancel(),
    verify: (cubit) {
      expect(cubit.state, isA<OrderDetailReady>());
      expect((cubit.state as OrderDetailReady).isCancelling, isFalse);
      expect(
        cubit.consumeCancelError(),
        'Only active orders can be cancelled',
      );
    },
  );

  test('consumeCancelError returns null when no error', () {
    when(() => repository.watchOrder('order-1'))
        .thenAnswer((_) => Stream.value(details));
    final cubit = buildCubit();
    expect(cubit.consumeCancelError(), isNull);
    cubit.close();
  });
}
