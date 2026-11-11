import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';
import 'package:sokosafi/features/business_orders/domain/repositories/business_orders_repository.dart';
import 'package:sokosafi/features/business_orders/presentation/bloc/confirm_pickup_cubit.dart';

class MockBusinessOrdersRepository extends Mock
    implements BusinessOrdersRepository {}

void main() {
  late MockBusinessOrdersRepository repository;

  ConfirmPickupCubit buildCubit() =>
      ConfirmPickupCubit(repository: repository, businessId: 'bakery');

  void whenConfirming(Future<void> Function() answer) {
    when(
      () => repository.confirmPickup(
        businessId: 'bakery',
        pickupCode: any(named: 'pickupCode'),
      ),
    ).thenAnswer((_) => answer());
  }

  setUp(() => repository = MockBusinessOrdersRepository());

  blocTest<ConfirmPickupCubit, ConfirmPickupState>(
    'a valid code ends in confirmed',
    setUp: () => whenConfirming(() async {}),
    build: buildCubit,
    act: (cubit) => cubit.confirm('SKS-4A7F2B'),
    expect: () => [
      const ConfirmPickupState(status: ConfirmPickupStatus.checking),
      const ConfirmPickupState(status: ConfirmPickupStatus.confirmed),
    ],
  );

  blocTest<ConfirmPickupCubit, ConfirmPickupState>(
    'an invalid code shows the reason',
    setUp: () => whenConfirming(
      () => Future.error(
        const BusinessOrdersFailure('No order with this code at your business'),
      ),
    ),
    build: buildCubit,
    act: (cubit) => cubit.confirm('SKS-2B3C4D'),
    expect: () => [
      const ConfirmPickupState(status: ConfirmPickupStatus.checking),
      const ConfirmPickupState(
        status: ConfirmPickupStatus.failed,
        errorMessage: 'No order with this code at your business',
      ),
    ],
  );

  blocTest<ConfirmPickupCubit, ConfirmPickupState>(
    'ignores repeated scans while a check is running',
    setUp: () => whenConfirming(() => Completer<void>().future),
    build: buildCubit,
    act: (cubit) {
      cubit.confirm('SKS-4A7F2B');
      cubit.confirm('SKS-4A7F2B');
    },
    expect: () => [
      const ConfirmPickupState(status: ConfirmPickupStatus.checking),
    ],
    verify: (_) => verify(
      () => repository.confirmPickup(
        businessId: 'bakery',
        pickupCode: 'SKS-4A7F2B',
      ),
    ).called(1),
  );
}
