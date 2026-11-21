import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/search_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/category_chips.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/location_notice.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/search_field.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/search_filter_sheet.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/search_result_card.dart';
import 'package:sokosafi/router/app_routes.dart';

/// Search by food or shop name, filter by category, price and distance.
/// Laid out like the "Near you" frame in Figma.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<SearchCubit>();
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            final locationMessage = state.locationMessage;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Near you', style: textTheme.headlineSmall),
                      Text(
                        'Surplus rescued nearby before closing',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: SearchField(onChanged: cubit.updateQuery),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _FilterButton(isActive: state.hasCustomLimits),
                        ],
                      ),
                      if (locationMessage != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        LocationNotice(
                          message: locationMessage,
                          onRetry: cubit.locate,
                        ),
                      ],
                    ],
                  ),
                ),
                CategoryChips(
                  selected: state.filter.category,
                  onSelected: cubit.selectCategory,
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(child: _Results(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    final results = state.results;
    return switch (state.status) {
      SearchStatus.loading => const LoadingView(),
      SearchStatus.failure => EmptyView(
        title: 'We could not load the food',
        message: state.errorMessage,
        actionLabel: 'Try again',
        onAction: cubit.watch,
      ),
      // Nothing is on sale at all, so the filters are not the reason.
      SearchStatus.ready when state.availableCount == 0 => const EmptyView(
        title: 'No surplus food right now',
        message:
            'Shops post food through the day. Search again once new '
            'listings go live.',
      ),
      SearchStatus.ready when results.isEmpty => EmptyView(
        title: 'No food matches',
        message: state.canClearFilters
            ? 'Try another word or clear the filters.'
            : 'Try another word.',
        actionLabel: state.canClearFilters ? 'Clear filters' : null,
        onAction: state.canClearFilters ? cubit.clearFilters : null,
      ),
      SearchStatus.ready => ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.sm,
          AppSpacing.pagePadding,
          AppSpacing.xl,
        ),
        itemCount: results.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.lg),
        itemBuilder: (context, index) {
          final result = results[index];
          final heroTag = 'search-${result.item.listing.id}';
          return StaggeredEntrance(
            index: index,
            child: SearchResultCard(
              result: result,
              heroTag: heroTag,
              onTap: () => context.push(
                AppRoutes.listingFor(result.item.listing.id),
                extra: heroTag,
              ),
            ),
          );
        },
      ),
    };
  }
}

/// Opens the price and distance filters; a dot shows when one is on.
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: isActive,
      smallSize: 10,
      backgroundColor: AppColors.primary,
      child: IconButton.outlined(
        tooltip: 'Filters',
        style: IconButton.styleFrom(
          fixedSize: const Size.square(AppSpacing.minTapTarget),
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        onPressed: () => showSearchFilterSheet(context),
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedFilter,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
