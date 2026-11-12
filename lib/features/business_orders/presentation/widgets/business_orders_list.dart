import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/features/business_orders/presentation/bloc/business_orders_cubit.dart';
import 'package:sokosafi/features/business_orders/presentation/widgets/business_order_card.dart';

class BusinessOrdersList extends StatelessWidget {
  const BusinessOrdersList({
    super.key,
    required this.state,
    required this.onConfirmPickup,
  });

  final BusinessOrdersState state;

  /// Opens Confirm Pickup. Only incoming orders show the button.
  final VoidCallback onConfirmPickup;

  @override
  Widget build(BuildContext context) {
    final orders = state.visibleOrders;
    if (orders.isEmpty) {
      final (title, message) = switch (state.tab) {
        BusinessOrdersTab.incoming => (
          'No orders waiting',
          'New orders show up here the moment a customer pays.',
        ),
        BusinessOrdersTab.completed => (
          'No pickups yet',
          'Orders you confirm at pickup show up here.',
        ),
        BusinessOrdersTab.cancelled => (
          'No cancelled orders',
          'Orders a customer cancels show up here.',
        ),
      };
      return EmptyView(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedShoppingBag01,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: title,
        message: message,
      );
    }
    return ListView.separated(
      // A key per tab rebuilds the list, so switching tabs replays the
      // entrance animation.
      key: PageStorageKey(state.tab),
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final item = orders[index];
        return StaggeredEntrance(
          key: ValueKey('${state.tab.name}-${item.order.id}'),
          index: index,
          child: BusinessOrderCard(
            item: item,
            onConfirmPickup: state.tab == BusinessOrdersTab.incoming
                ? onConfirmPickup
                : null,
          ),
        );
      },
    );
  }
}
