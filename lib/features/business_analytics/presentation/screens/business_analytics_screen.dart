import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/section_header.dart';
import 'package:sokosafi/core/widgets/skeleton_loading_list.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/core/widgets/stat_tile.dart';
import 'package:sokosafi/features/business_analytics/domain/entities/analytics_summary.dart';
import 'package:sokosafi/features/business_analytics/presentation/bloc/analytics_cubit.dart';
import 'package:sokosafi/features/business_analytics/presentation/widgets/analytics_range_selector.dart';
import 'package:sokosafi/features/business_analytics/presentation/widgets/revenue_chart_card.dart';
import 'package:sokosafi/features/business_analytics/presentation/widgets/top_items_card.dart';
import 'package:sokosafi/features/business_dashboard/presentation/widgets/compact_number.dart';
import 'package:sokosafi/features/business_orders/data/repositories/firestore_business_orders_repository.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/owned_business_gate.dart';
import 'package:sokosafi/features/reviews/data/repositories/firestore_review_repository.dart';

/// Revenue over time, orders, average rating and top-selling items.
class BusinessAnalyticsScreen extends StatelessWidget {
  const BusinessAnalyticsScreen({super.key, required this.ownerId});

  final String ownerId;

  @override
  Widget build(BuildContext context) {
    return OwnedBusinessGate(
      ownerId: ownerId,
      title: 'Analytics',
      builder: (context, business) => BlocProvider(
        create: (_) => AnalyticsCubit(
          ordersRepository: FirestoreBusinessOrdersRepository(),
          reviewRepository: FirestoreReviewRepository(),
          businessId: business.id,
        )..watch(),
        child: const _AnalyticsView(),
      ),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: BlocConsumer<AnalyticsCubit, AnalyticsState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == AnalyticsStatus.failure,
        listener: (context, state) => AppSnackBar.showError(
          context,
          state.errorMessage ?? 'We could not load your analytics',
        ),
        builder: (context, state) {
          final cubit = context.read<AnalyticsCubit>();
          final summary = state.summary;
          return Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              AnalyticsRangeSelector(
                selected: state.range,
                onSelected: cubit.selectRange,
              ),
              Expanded(
                child: switch (state.status) {
                  AnalyticsStatus.loading => const SkeletonLoadingList(),
                  AnalyticsStatus.failure => EmptyView(
                    title: 'We could not load your analytics',
                    message: state.errorMessage,
                    actionLabel: 'Try again',
                    onAction: cubit.watch,
                  ),
                  AnalyticsStatus.ready when summary != null => _AnalyticsBody(
                    summary: summary,
                  ),
                  AnalyticsStatus.ready => const SkeletonLoadingList(),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({required this.summary});

  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final averageRating = summary.averageRating;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        StaggeredEntrance(index: 0, child: RevenueChartCard(summary: summary)),
        const SizedBox(height: AppSpacing.md),
        StaggeredEntrance(
          index: 1,
          child: Row(
            children: [
              Expanded(
                child: StatTile(
                  value: compactNumber(summary.itemsSold),
                  label: 'Items sold',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(
                  value: compactNumber(summary.orderCount),
                  label: 'Orders',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(
                  value: averageRating == null
                      ? '-'
                      : averageRating.toStringAsFixed(1),
                  label: 'Avg rating (${summary.ratingCount})',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Top items'),
        const SizedBox(height: AppSpacing.sm),
        StaggeredEntrance(
          index: 2,
          child: TopItemsCard(items: summary.topItems),
        ),
      ],
    );
  }
}
