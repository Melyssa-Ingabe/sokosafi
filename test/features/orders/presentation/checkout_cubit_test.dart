import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';
import 'package:sokosafi/features/orders/domain/failures/orders_failure.dart';
import 'package:sokosafi/features/orders/domain/repositories/orders_repository.dart';
import 'package:sokosafi/features/orders/presentation/cubit/checkout_cubit.dart';

import '../../../helpers/order_fixtures.dart';

class MockOrdersRepository extends Mock implements OrdersRepository {}

void main() {
  late MockOrdersRepository repository;

  CheckoutCubit buildCubit() => CheckoutCubit(
    repository: repository,
    customerId: 'customer-1',
    listingId: 'bread',
    preferredPaymentMethod: PaymentMethod.airtelMoney,
  );

  CheckoutState readyState({int quantity = 1, int quantityLeft = 3}) =>
      CheckoutState(
        paymentMethod: PaymentMethod.airtelMoney,
        status: CheckoutStatus.ready,
        item: breadCheckout(quantityLeft: quantityLeft),
        quantity: quantity,
      );

  setUpAll(() => registerFallbackValue(PaymentMethod.mtnMomo));

  setUp(() => repository = MockOrdersRepository());

  test('starts with the preferred payment method from settings', () {
    expect(buildCubit().state.paymentMethod, PaymentMethod.airtelMoney);
  });

  blocTest<CheckoutCubit, CheckoutState>(
    'loads the item to check out',
    setUp: () =>
        when(() => repository.loadCheckoutItem('bread'))
            .thenAnswer((_) async => breadCheckout()),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [
      const CheckoutState(paymentMethod: PaymentMethod.airtelMoney),
      readyState(),
    ],
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'shows a polite error when the item cannot load',
    setUp: () =>
        when(() => repository.loadCheckoutItem('bread'))
            .thenThrow(const OrdersFailure('This item is no longer available')),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [
      const CheckoutState(paymentMethod: PaymentMethod.airtelMoney),
      const CheckoutState(
        paymentMethod: PaymentMethod.airtelMoney,
        status: CheckoutStatus.failure,
        errorMessage: 'This item is no longer available',
      ),
    ],
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'keeps the quantity between one and what is left',
    build: buildCubit,
    seed: () => readyState(quantityLeft: 2),
    act: (cubit) => cubit
      ..decreaseQuantity()
      ..increaseQuantity()
      ..increaseQuantity(),
    expect: () => [readyState(quantity: 2, quantityLeft: 2)],
  );

  test('totals follow the quantity', () {
    final state = readyState(quantity: 2);

    expect(state.originalTotal, 2000);
    expect(state.total, 1200);
    expect(state.discount, 800);
  });

  blocTest<CheckoutCubit, CheckoutState>(
    'places the order with the chosen quantity and payment method',
    setUp: () => when(
      () => repository.placeOrder(
        customerId: any(named: 'customerId'),
        listingId: any(named: 'listingId'),
        quantity: any(named: 'quantity'),
        paymentMethod: any(named: 'paymentMethod'),
      ),
    ).thenAnswer((_) async => 'order-1'),
    build: buildCubit,
    seed: () => readyState(quantity: 2),
    act: (cubit) => cubit.placeOrder(),
    expect: () => [
      readyState(quantity: 2).copyWith(isSubmitting: true),
      readyState(quantity: 2).copyWith(placedOrderId: 'order-1'),
    ],
    verify: (_) => verify(
      () => repository.placeOrder(
        customerId: 'customer-1',
        listingId: 'bread',
        quantity: 2,
        paymentMethod: PaymentMethod.airtelMoney,
      ),
    ).called(1),
  );

  blocTest<CheckoutCubit, CheckoutState>(
    'reports a failed order and lets the customer retry',
    setUp: () => when(
      () => repository.placeOrder(
        customerId: any(named: 'customerId'),
        listingId: any(named: 'listingId'),
        quantity: any(named: 'quantity'),
        paymentMethod: any(named: 'paymentMethod'),
      ),
    ).thenThrow(const OrdersFailure('Only 1 left. Lower the quantity')),
    build: buildCubit,
    seed: () => readyState(quantity: 2),
    act: (cubit) => cubit.placeOrder(),
    expect: () => [
      readyState(quantity: 2).copyWith(isSubmitting: true),
      readyState(quantity: 2)
          .copyWith(errorMessage: 'Only 1 left. Lower the quantity'),
    ],
  );
}
