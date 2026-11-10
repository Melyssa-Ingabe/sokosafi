import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/features/orders/presentation/cubit/my_orders_cubit.dart';
import 'package:sokosafi/features/orders/presentation/widgets/order_card.dart';
import 'package:sokosafi/router/app_routes.dart';

class OrdersList extends StatelessWidget {
  const OrdersList({super.key, required this.state});

  final MyOrdersState state;

  Future<void> _confirmCancel(BuildContext context, String orderId) async {
    final cubit = context.read<MyOrdersCubit>();
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        title: const Text('Cancel this order?'),
        content: const Text(
          'Your items go back on sale for other customers. This cannot be '
          'undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep order'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.cancelOrder(orderId);
  }

  @override
  Widget build(BuildContext context) {
    final orders = state.visibleOrders;
    if (orders.isEmpty) {
      final isActiveTab = state.tab == OrdersTab.active;
      return EmptyView(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedShoppingBag01,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: isActiveTab ? 'No active orders' : 'No past orders yet',
        message: isActiveTab
            ? 'Reserve a surplus bag and its pickup pass will show up here.'
            : 'Orders you collect or cancel will show up here.',
      );
    }
    final cubit = context.read<MyOrdersCubit>();
    return ListView.separated(
      // A key per tab rebuilds the list, so switching tabs replays the entrance.
      key: PageStorageKey(state.tab),
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final details = orders[index];
        final orderId = details.order.id;
        return StaggeredEntrance(
          key: ValueKey('${state.tab.name}-$orderId'),
          index: index,
          child: OrderCard(
            details: details,
            isExpanded: state.expandedOrderId == orderId,
            isCancelling: state.cancellingOrderId == orderId,
            onToggle: () => cubit.toggleExpanded(orderId),
            onShowPass: () => context.push(AppRoutes.orderFor(orderId)),
            onCancel: () => _confirmCancel(context, orderId),
          ),
        );
      },
    );
  }
}
