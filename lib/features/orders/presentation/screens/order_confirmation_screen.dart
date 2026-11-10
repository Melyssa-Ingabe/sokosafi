import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/features/orders/presentation/cubit/order_detail_cubit.dart';
import 'package:sokosafi/features/orders/presentation/widgets/order_confirmation_body.dart';
import 'package:sokosafi/router/app_routes.dart';

/// Shown right after checkout and whenever a customer opens their pickup
/// pass from My Orders.
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.myOrders);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () => _close(context),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: BlocBuilder<OrderDetailCubit, OrderDetailState>(
        builder: (context, state) {
          return switch (state) {
            OrderDetailLoading() => const LoadingView(),
            OrderDetailFailure(:final message) => EmptyView(
              title: 'We could not load this order',
              message: message,
              actionLabel: 'Try again',
              onAction: context.read<OrderDetailCubit>().watch,
            ),
            OrderDetailReady(:final details) => OrderConfirmationBody(
              details: details,
            ),
          };
        },
      ),
    );
  }
}
