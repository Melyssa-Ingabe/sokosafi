import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/orders/data/repositories/firestore_orders_repository.dart';
import 'package:sokosafi/features/orders/domain/repositories/orders_repository.dart';
import 'package:sokosafi/features/orders/presentation/cubit/checkout_cubit.dart';
import 'package:sokosafi/features/orders/presentation/cubit/my_orders_cubit.dart';
import 'package:sokosafi/features/orders/presentation/cubit/order_detail_cubit.dart';
import 'package:sokosafi/features/orders/presentation/screens/checkout_screen.dart';
import 'package:sokosafi/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:sokosafi/features/orders/presentation/screens/order_confirmation_screen.dart';
import 'package:sokosafi/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:sokosafi/router/app_page.dart';
import 'package:sokosafi/router/app_routes.dart';

/// Checkout and order routes. The router's redirect guarantees a signed-in
/// user before any of these build.
List<GoRoute> buildOrdersRoutes({OrdersRepository Function()? repository}) {
  final createRepository = repository ?? FirestoreOrdersRepository.new;
  return [
    GoRoute(
      path: AppRoutes.checkout,
      pageBuilder: (context, state) => buildAppPage(
        state: state,
        child: BlocProvider(
          create: (context) => CheckoutCubit(
            repository: createRepository(),
            customerId: context.read<AuthBloc>().state.user?.uid ?? '',
            listingId: state.pathParameters['listingId'] ?? '',
            preferredPaymentMethod: context
                .read<SettingsCubit>()
                .state
                .preferredPaymentMethod,
          )..load(),
          child: const CheckoutScreen(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.myOrders,
      pageBuilder: (context, state) => buildAppPage(
        state: state,
        child: BlocProvider(
          create: (context) => MyOrdersCubit(
            repository: createRepository(),
            customerId: context.read<AuthBloc>().state.user?.uid ?? '',
          )..watch(),
          child: const MyOrdersScreen(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.orderDetail,
      pageBuilder: (context, state) => buildAppPage(
        state: state,
        child: BlocProvider(
          create: (_) => OrderDetailCubit(
            repository: createRepository(),
            orderId: state.pathParameters['orderId'] ?? '',
          )..watch(),
          child: const OrderConfirmationScreen(),
        ),
      ),
    ),
  ];
}
