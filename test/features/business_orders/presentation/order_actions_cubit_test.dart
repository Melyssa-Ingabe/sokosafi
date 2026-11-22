import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/business_orders/domain/entities/business_order.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';
import 'package:sokosafi/features/business_orders/domain/repositories/business_orders_repository.dart';
import 'package:sokosafi/features/business_orders/presentation/bloc/order_actions_cubit.dart';
import 'package:sokosafi/features/orders/domain/entities/customer_order.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';

class MockBusinessOrdersRepository extends Mock
    implements BusinessOrdersRepository {}

void main() {
  late MockBusinessOrdersRepository repository;
  late OrderActionsCubit cubit;

  final item = BusinessOrder(
    listingTitle: 'Bread',
    order: CustomerOrder(
      id: 'order1',
      customerId: 'customer',
      businessId: 'bakery',
      listingId: 'bread',
      quantity: 2,
      total: 1200,
      pickupCode: 'SKS-4A7F2B',
      paymentMethod: PaymentMethod.mtnMomo,
      status: OrderStatus.paid,
      createdAt: DateTime(2026, 11, 22, 10),
    ),
  );

  setUp(() {
    repository = MockBusinessOrdersRepository();
    cubit = OrderActionsCubit(repository: repository, businessId: 'bakery');
  });

  tearDown(() => cubit.close());

  test('the tick confirms the order with its own pickup code', () async {
    when(
      () => repository.confirmPickup(
        businessId: 'bakery',
        pickupCode: 'SKS-4A7F2B',
      ),
    ).thenAnswer((_) async {});

    await cubit.confirm(item);

    expect(cubit.state.busyOrderId, isNull);
    expect(cubit.state.feedback?.isError, isFalse);
  });

  test('the cross cancels the order', () async {
    when(() => repository.cancelOrder(businessId: 'bakery', orderId: 'order1'))
        .thenAnswer((_) async {});

    await cubit.cancel(item);

    verify(
      () => repository.cancelOrder(businessId: 'bakery', orderId: 'order1'),
    ).called(1);
    expect(cubit.state.feedback?.isError, isFalse);
  });

  test('a failure becomes a polite error message', () async {
    when(() => repository.cancelOrder(businessId: 'bakery', orderId: 'order1'))
        .thenThrow(
          const BusinessOrdersFailure('This order was already picked up'),
        );

    await cubit.cancel(item);

    expect(cubit.state.feedback?.isError, isTrue);
    expect(cubit.state.feedback?.message, 'This order was already picked up');
  });

  test('a second tap while saving is ignored', () async {
    when(
      () => repository.cancelOrder(businessId: 'bakery', orderId: 'order1'),
    ).thenAnswer((_) => Future<void>.delayed(const Duration(milliseconds: 10)));

    await Future.wait([cubit.cancel(item), cubit.cancel(item)]);

    verify(
      () => repository.cancelOrder(businessId: 'bakery', orderId: 'order1'),
    ).called(1);
  });
}
