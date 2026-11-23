import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/features/discovery/domain/entities/search_filter.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/search_cubit.dart';
import 'package:sokosafi/features/settings/domain/entities/app_settings.dart';

/// Opens the price and distance filters. Each chip applies straight away,
/// so the results behind the sheet update while it is open.
Future<void> showSearchFilterSheet(BuildContext context) {
  final cubit = context.read<SearchCubit>();
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) =>
        BlocProvider.value(value: cubit, child: const SearchFilterSheet()),
  );
}

class SearchFilterSheet extends StatelessWidget {
  const SearchFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final cubit = context.read<SearchCubit>();
        final filter = state.filter;
        final hasLocation = state.location != null;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              0,
              AppSpacing.pagePadding,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filters', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.lg),
                Text('Highest price', style: textTheme.labelMedium),
                const SizedBox(height: AppSpacing.sm),
                _OptionChips<int>(
                  options: SearchFilter.priceOptionsRwf,
                  selected: filter.maxPriceRwf,
                  labelFor: (price) => 'Up to ${Formatters.rwf(price)}',
                  onSelected: (price) => cubit.applyLimits(
                    maxPriceRwf: price,
                    radiusKm: filter.radiusKm,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Distance', style: textTheme.labelMedium),
                if (!hasLocation)
                  Text(
                    'Allow location to use this filter',
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                _OptionChips<int>(
                  options: AppSettings.searchRadiusOptionsKm,
                  selected: filter.radiusKm,
                  labelFor: (km) => 'Within $km km',
                  enabled: hasLocation,
                  onSelected: (km) => cubit.applyLimits(
                    maxPriceRwf: filter.maxPriceRwf,
                    radiusKm: km,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: state.canClearFilters
                            ? cubit.clearFilters
                            : null,
                        child: const Text('Clear filters'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Show ${state.results.length}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "Any" plus one chip per option. Null means "Any".
class _OptionChips<T> extends StatelessWidget {
  const _OptionChips({
    required this.options,
    required this.selected,
    required this.labelFor,
    required this.onSelected,
    this.enabled = true,
  });

  final List<T> options;
  final T? selected;
  final String Function(T option) labelFor;
  final ValueChanged<T?> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ChoiceChip(
          label: const Text('Any'),
          selected: selected == null,
          onSelected: enabled ? (_) => onSelected(null) : null,
        ),
        for (final option in options)
          ChoiceChip(
            label: Text(labelFor(option)),
            selected: selected == option,
            onSelected: enabled ? (_) => onSelected(option) : null,
          ),
      ],
    );
  }
}
