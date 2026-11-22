import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/skeleton_empty_view.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/features/business_orders/presentation/bloc/business_orders_cubit.dart';
import 'package:sokosafi/features/business_orders/presentation/widgets/business_order_card.dart';

class BusinessOrdersList extends StatelessWidget {
  const BusinessOrdersList({super.key, required this.state});

  final BusinessOrdersState state;

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
      return SkeletonEmptyView(
        key: ValueKey(state.tab),
        title: title,
        message: message,
      );
    }
    return ListView.separated(
      key: PageStorageKey(state.tab),
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final item = orders[index];
        return StaggeredEntrance(
          key: ValueKey('${state.tab.name}-${item.order.id}'),
          index: index,
          child: BusinessOrderCard(item: item),
        );
      },
    );
  }
}
