import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sokosafi/features/auth/domain/entities/app_user.dart';
import 'package:sokosafi/features/auth/domain/entities/user_role.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/orders/domain/entities/payment_method.dart';
import 'package:sokosafi/features/orders/domain/failures/orders_failure.dart';
import 'package:sokosafi/features/orders/domain/repositories/orders_repository.dart';
import 'package:sokosafi/features/orders/presentation/cubit/checkout_cubit.dart';
import 'package:sokosafi/features/orders/presentation/screens/checkout_screen.dart';

import '../../../../helpers/order_fixtures.dart';

class MockOrdersRepository extends Mock implements OrdersRepository {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

AppUser _customer({required String phone}) => AppUser(
  uid: 'customer-1',
  email: 'prince@example.com',
  name: 'Prince',
  phone: phone,
  role: UserRole.customer,
  photoUrl: '',
  foodPreferences: const [],
  isEmailVerified: true,
);

void main() {
  late MockOrdersRepository repository;
  late MockAuthBloc authBloc;

  setUpAll(() => registerFallbackValue(PaymentMethod.mtnMomo));

  setUp(() {
    repository = MockOrdersRepository();
    authBloc = MockAuthBloc();
    when(() => repository.loadCheckoutItem('bread'))
        .thenAnswer((_) async => breadCheckout());
  });

  Future<void> pumpCheckout(
    WidgetTester tester, {
    required String phone,
  }) async {
    when(() => authBloc.state).thenReturn(
      AuthState(
        status: AuthStatus.authenticated,
        user: _customer(phone: phone),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: BlocProvider(
            create: (_) => CheckoutCubit(
              repository: repository,
              customerId: 'customer-1',
              listingId: 'bread',
              preferredPaymentMethod: PaymentMethod.mtnMomo,
            )..load(),
            child: const CheckoutScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapConfirm(WidgetTester tester) async {
    await tester.tap(find.textContaining('Confirm payment'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the item, business and total', (tester) async {
    await pumpCheckout(tester, phone: '0788412890');

    expect(find.text('Boulangerie de Kigali'), findsOneWidget);
    expect(find.text('Fresh Artisan Breads'), findsOneWidget);
    expect(find.text('Confirm payment · 600 RWF'), findsOneWidget);
  });

  testWidgets('blocks payment without a mobile money number', (tester) async {
    await pumpCheckout(tester, phone: '');

    await tapConfirm(tester);

    expect(find.text('Enter your phone number'), findsOneWidget);
    verifyNever(
      () => repository.placeOrder(
        customerId: any(named: 'customerId'),
        listingId: any(named: 'listingId'),
        quantity: any(named: 'quantity'),
        paymentMethod: any(named: 'paymentMethod'),
      ),
    );
  });

  testWidgets('shows a polite message when the order fails', (tester) async {
    when(
      () => repository.placeOrder(
        customerId: any(named: 'customerId'),
        listingId: any(named: 'listingId'),
        quantity: any(named: 'quantity'),
        paymentMethod: any(named: 'paymentMethod'),
      ),
    ).thenThrow(const OrdersFailure('This item is no longer available'));
    await pumpCheckout(tester, phone: '0788412890');

    await tapConfirm(tester);

    expect(find.text('This item is no longer available'), findsOneWidget);
  });
}
