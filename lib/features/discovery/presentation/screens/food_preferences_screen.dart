import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/food_preferences_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/preference_tile.dart';
import 'package:sokosafi/features/listings/domain/entities/listing_category.dart';

/// The Food Preferences frame in Figma, with the four categories a listing
/// can have instead of Figma's twelve, which the data model does not hold.
class FoodPreferencesScreen extends StatelessWidget {
  const FoodPreferencesScreen({super.key});

  static const double _tileHeight = 100;
  static const double _tileGap = 10;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocListener<FoodPreferencesCubit, FoodPreferencesState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case FoodPreferencesStatus.saved:
            AppSnackBar.showSuccess(context, 'Your feed is updated');
            if (context.canPop()) context.pop();
          case FoodPreferencesStatus.failure:
            AppSnackBar.showError(
              context,
              state.errorMessage ?? 'We could not save your choices',
            );
          case FoodPreferencesStatus.editing:
          case FoodPreferencesStatus.saving:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Food preferences')),
        body: BlocBuilder<FoodPreferencesCubit, FoodPreferencesState>(
          builder: (context, state) {
            final cubit = context.read<FoodPreferencesCubit>();
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.xl,
                AppSpacing.pagePadding,
                AppSpacing.xl,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pick what you like',
                        style: textTheme.headlineSmall,
                      ),
                    ),
                    _SelectedCount(count: state.selected.length),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'We show these first in your feed. Leave them all off to '
                  'see every category in the usual order.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: _tileHeight,
                    mainAxisSpacing: _tileGap,
                    crossAxisSpacing: _tileGap,
                  ),
                  children: [
                    for (final category in ListingCategory.values)
                      PreferenceTile(
                        category: category,
                        isSelected: state.selected.contains(category),
                        onTap: () => cubit.toggle(category),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                const _ImpactNote(),
              ],
            );
          },
        ),
        bottomNavigationBar: const _SaveBar(),
      ),
    );
  }
}

class _SelectedCount extends StatelessWidget {
  const _SelectedCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.brandSubtle,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          '$count selected',
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _ImpactNote extends StatelessWidget {
  const _ImpactNote();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 32,
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedFavourite,
                    size: 16,
                    color: AppColors.surface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Food you like comes first, so you spot it before it is '
                'gone.',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The sticky "Save preferences" button, off until something changes.
class _SaveBar extends StatelessWidget {
  const _SaveBar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FoodPreferencesCubit>().state;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: 12,
          ),
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: state.hasChanges && !state.isSaving
                  ? context.read<FoodPreferencesCubit>().save
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const StadiumBorder(),
              ),
              child: state.isSaving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.surface,
                      ),
                    )
                  : const Text('Save preferences'),
            ),
          ),
        ),
      ),
    );
  }
}
