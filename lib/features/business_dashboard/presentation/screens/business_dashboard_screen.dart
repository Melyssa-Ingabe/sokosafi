import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/brand_header.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/section_header.dart';
import 'package:sokosafi/core/widgets/skeleton_empty_view.dart';
import 'package:sokosafi/core/widgets/skeleton_loading_list.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/core/widgets/stat_tile.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';
import 'package:sokosafi/features/business_dashboard/domain/entities/dashboard_summary.dart';
import 'package:sokosafi/features/business_dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:sokosafi/features/business_dashboard/presentation/widgets/compact_number.dart';
import 'package:sokosafi/features/business_dashboard/presentation/widgets/listing_progress_card.dart';
import 'package:sokosafi/features/business_dashboard/presentation/widgets/recent_orders_card.dart';
import 'package:sokosafi/features/business_orders/data/repositories/firestore_business_orders_repository.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/owned_business_gate.dart';
import 'package:sokosafi/features/listings/data/repositories/firestore_listing_repository.dart';
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
      floatingActionButton: TapScale(
        child: FloatingActionButton(
          tooltip: 'Scan a pickup code',
          heroTag: null,
          onPressed: () => context.push(AppRoutes.confirmPickup),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 2,
          shape: const CircleBorder(),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedQrCode,
            size: 28,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              child: BrandHeader(locationLabel: business.address),
            ),
            Expanded(
              child: BlocConsumer<DashboardCubit, DashboardState>(
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
                    DashboardStatus.failure => EmptyView(
                      title: 'We could not load your dashboard',
                      message: state.errorMessage,
                      actionLabel: 'Try again',
                      onAction: context.read<DashboardCubit>().watch,
                    ),
                    DashboardStatus.ready when summary != null =>
                      _DashboardBody(business: business, summary: summary),
                    _ => const SkeletonLoadingList(),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.business, required this.summary});

  final Business business;
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      // Extra space at the bottom so the QR button never covers the last
      // card.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.lg,
        AppSpacing.pagePadding,
        96,
      ),
      children: [
        _BusinessRow(business: business),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Today',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatTile(
                value: '${summary.activeListings.length}',
                label: 'Active listings',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatTile(
                value: '${summary.itemsSoldToday}',
                label: 'Items sold',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatTile(
                value: compactNumber(summary.revenueToday),
                label: 'RWF recovered',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(
          title: 'Active listings',
          actionLabel: 'Manage',
          onAction: () => context.push(AppRoutes.myListings),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (summary.activeListings.isEmpty)
          const SizedBox(
            height: 220,
            child: SkeletonEmptyView(
              rowCount: 2,
              title: 'No listings on sale',
              message: 'Tap + List to put surplus food up for sale',
            ),
          )
        else
          for (final (index, progress) in summary.activeListings.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: StaggeredEntrance(
                index: index,
                child: ListingProgressCard(
                  progress: progress,
                  onTap: () => context.push(
                    AppRoutes.editListing,
                    extra: progress.listing,
                  ),
                ),
              ),
            ),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(
          title: 'Recent orders',
          actionLabel: 'View all (${summary.totalOrders})',
          isActionSubtle: true,
          onAction: () => context.go(AppRoutes.businessOrders),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (summary.recentOrders.isEmpty)
          const SizedBox(
            height: 220,
            child: SkeletonEmptyView(
              rowCount: 2,
              title: 'No orders yet',
              message: 'Orders show up here as soon as customers reserve',
            ),
          )
        else
          RecentOrdersCard(
            orders: summary.recentOrders,
            onConfirmPickup: () => context.push(AppRoutes.confirmPickup),
          ),
      ],
    );
  }
}

/// Shop icon, name and the "Selling" pill that switches back to buying.
class _BusinessRow extends StatelessWidget {
  const _BusinessRow({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        SizedBox.square(
          dimension: 44,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: scheme.surfaceContainerHighest,
              shape: const CircleBorder(),
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedStore01,
                size: 22,
                color: scheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            business.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        TapScale(
          child: Tooltip(
            message: 'Switch to buying',
            child: Material(
              color: scheme.surfaceContainerHighest,
              shape: const StadiumBorder(),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => context.go(AppRoutes.customerHome),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppSpacing.minTapTarget,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIcons
                              .strokeRoundedArrowDataTransferHorizontal,
                          size: 18,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Selling',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
