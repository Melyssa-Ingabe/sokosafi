import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/theme/app_text_styles.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/core/widgets/section_header.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/features/business_dashboard/domain/entities/dashboard_summary.dart';
import 'package:sokosafi/features/business_dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:sokosafi/features/business_dashboard/presentation/widgets/compact_number.dart';
import 'package:sokosafi/features/business_dashboard/presentation/widgets/dashboard_stat_tile.dart';
import 'package:sokosafi/features/business_dashboard/presentation/widgets/items_rescued_card.dart';
import 'package:sokosafi/features/business_dashboard/presentation/widgets/listing_progress_card.dart';
import 'package:sokosafi/features/business_orders/data/repositories/firestore_business_orders_repository.dart';
import 'package:sokosafi/features/business_orders/presentation/widgets/business_order_card.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/owned_business_gate.dart';
import 'package:sokosafi/features/listings/data/repositories/firestore_listing_repository.dart';
import 'package:sokosafi/features/orders/domain/entities/order_status.dart';
import 'package:sokosafi/router/app_routes.dart';

/// Live overview of the owner's business: today's numbers, active
/// listings, recent orders and food rescued.
class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key, required this.ownerId});

  final String ownerId;

  @override
  Widget build(BuildContext context) {
    return OwnedBusinessGate(
      ownerId: ownerId,
      title: 'Dashboard',
      builder: (context, business) => BlocProvider(
        create: (_) => DashboardCubit(
          listingRepository: FirestoreListingRepository(),
          ordersRepository: FirestoreBusinessOrdersRepository(),
          businessId: business.id,
        )..watch(),
        child: _DashboardView(business: business),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          business.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: BlocConsumer<DashboardCubit, DashboardState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == DashboardStatus.failure,
        listener: (context, state) => AppSnackBar.showError(
          context,
          state.errorMessage ?? 'We could not load your dashboard',
        ),
        builder: (context, state) {
          final summary = state.summary;
          return switch (state.status) {
            DashboardStatus.loading => const LoadingView(),
            DashboardStatus.failure => EmptyView(
              title: 'We could not load your dashboard',
              message: state.errorMessage,
              actionLabel: 'Try again',
              onAction: context.read<DashboardCubit>().watch,
            ),
            DashboardStatus.ready when summary != null => _DashboardBody(
              summary: summary,
            ),
            DashboardStatus.ready => const LoadingView(),
          };
        },
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final sectionStyle = AppTextStyles.label.copyWith(
      color: AppColors.textSecondary,
    );
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        Text('Today', style: sectionStyle),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: DashboardStatTile(
                value: '${summary.activeListings.length}',
                label: 'Active listings',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: DashboardStatTile(
                value: '${summary.itemsSoldToday}',
                label: 'Items sold',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: DashboardStatTile(
                value: compactNumber(summary.revenueToday),
                label: 'RWF recovered',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Active listings'),
        const SizedBox(height: AppSpacing.sm),
        if (summary.activeListings.isEmpty)
          Text(
            'No listings on sale right now.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          )
        else
          for (final (index, progress) in summary.activeListings.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: StaggeredEntrance(
                index: index,
                child: ListingProgressCard(progress: progress),
              ),
            ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: 'Recent orders',
          actionLabel: 'View all',
          onAction: () => context.go(AppRoutes.businessOrders),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (summary.recentOrders.isEmpty)
          Text(
            'Orders show up here as soon as customers reserve.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          )
        else
          for (final item in summary.recentOrders)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: BusinessOrderCard(
                item: item,
                onConfirmPickup: item.order.status == OrderStatus.paid
                    ? () => context.push(AppRoutes.confirmPickup)
                    : null,
              ),
            ),
        const SizedBox(height: AppSpacing.lg),
        Text('Waste diverted', style: sectionStyle),
        const SizedBox(height: AppSpacing.sm),
        ItemsRescuedCard(itemsRescued: summary.itemsRescued),
      ],
    );
  }
}
