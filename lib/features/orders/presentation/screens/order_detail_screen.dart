import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/features/orders/presentation/cubit/order_detail_cubit.dart';
import 'package:sokosafi/features/orders/presentation/widgets/order_detail_body.dart';
import 'package:sokosafi/router/app_routes.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

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
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => _close(context),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        title: const Text('Order details'),
      ),
      body: BlocConsumer<OrderDetailCubit, OrderDetailState>(
        listenWhen: (previous, current) {
          if (previous is! OrderDetailReady || current is! OrderDetailReady) {
            return false;
          }
          if (previous.isCancelling && !current.isCancelling) return true;
          if (previous.details.order.status != current.details.order.status) {
            return true;
          }
          return false;
        },
        listener: (context, state) {
          final cubit = context.read<OrderDetailCubit>();
          final error = cubit.consumeCancelError();
          if (error != null) {
            AppSnackBar.showError(context, error);
            return;
          }
          if (state is OrderDetailReady &&
              state.details.order.status == OrderStatus.cancelled) {
            AppSnackBar.showSuccess(context, 'Order cancelled');
          }
        },
        builder: (context, state) {
          return switch (state) {
            OrderDetailLoading() => const LoadingView(),
            OrderDetailFailure(:final message) => EmptyView(
              title: 'Could not load order',
              message: message,
              actionLabel: 'Try again',
              onAction: context.read<OrderDetailCubit>().watch,
            ),
            OrderDetailReady(:final details, :final isCancelling) =>
              OrderDetailBody(
                details: details,
                isCancelling: isCancelling,
                onCancel: context.read<OrderDetailCubit>().cancel,
              ),
          };
        },
      ),
    );
  }
}
