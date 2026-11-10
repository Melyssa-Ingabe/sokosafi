import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/features/orders/presentation/cubit/my_orders_cubit.dart';
import 'package:sokosafi/features/orders/presentation/widgets/orders_list.dart';
import 'package:sokosafi/features/orders/presentation/widgets/orders_tab_switcher.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: BlocConsumer<MyOrdersCubit, MyOrdersState>(
        listenWhen: (previous, current) =>
            current.feedback != null && previous.feedback != current.feedback,
        listener: (context, state) {
          final feedback = state.feedback!;
          if (feedback.isError) {
            AppSnackBar.showError(context, feedback.message);
          } else {
            AppSnackBar.showSuccess(context, feedback.message);
          }
        },
        builder: (context, state) {
          final cubit = context.read<MyOrdersCubit>();
          return switch (state.status) {
            MyOrdersStatus.loading => const LoadingView(),
            MyOrdersStatus.failure => EmptyView(
              title: 'We could not load your orders',
              message: state.errorMessage,
              actionLabel: 'Try again',
              onAction: cubit.watch,
            ),
            MyOrdersStatus.ready => Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                OrdersTabSwitcher(
                  selected: state.tab,
                  activeCount: state.activeOrders.length,
                  pastCount: state.pastOrders.length,
                  onSelected: cubit.selectTab,
                ),
                Expanded(child: OrdersList(state: state)),
              ],
            ),
          };
        },
      ),
    );
  }
}
