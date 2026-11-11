import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/features/business_orders/data/repositories/firestore_business_orders_repository.dart';
import 'package:sokosafi/features/business_orders/presentation/bloc/business_orders_cubit.dart';
import 'package:sokosafi/features/business_orders/presentation/widgets/business_orders_list.dart';
import 'package:sokosafi/features/business_orders/presentation/widgets/business_orders_tab_bar.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/owned_business_gate.dart';

/// Every order for the owner's business, live, split into tabs.
class BusinessOrdersScreen extends StatelessWidget {
  const BusinessOrdersScreen({super.key, required this.ownerId});

  final String ownerId;

  @override
  Widget build(BuildContext context) {
    return OwnedBusinessGate(
      ownerId: ownerId,
      title: 'Orders',
      builder: (context, business) => BlocProvider(
        create: (_) => BusinessOrdersCubit(
          repository: FirestoreBusinessOrdersRepository(),
          businessId: business.id,
        )..watch(),
        child: const _BusinessOrdersView(),
      ),
    );
  }
}

class _BusinessOrdersView extends StatelessWidget {
  const _BusinessOrdersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: BlocConsumer<BusinessOrdersCubit, BusinessOrdersState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == BusinessOrdersStatus.failure,
        listener: (context, state) => AppSnackBar.showError(
          context,
          state.errorMessage ?? 'We could not load your orders',
        ),
        builder: (context, state) {
          final cubit = context.read<BusinessOrdersCubit>();
          return switch (state.status) {
            BusinessOrdersStatus.loading => const LoadingView(),
            BusinessOrdersStatus.failure => EmptyView(
              title: 'We could not load your orders',
              message: state.errorMessage,
              actionLabel: 'Try again',
              onAction: cubit.watch,
            ),
            BusinessOrdersStatus.ready => Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                BusinessOrdersTabBar(
                  selected: state.tab,
                  countFor: (tab) => state.ordersFor(tab).length,
                  onSelected: cubit.selectTab,
                ),
                Expanded(child: BusinessOrdersList(state: state)),
              ],
            ),
          };
        },
      ),
    );
  }
}
