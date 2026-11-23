import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/skeleton_empty_view.dart';
import 'package:sokosafi/core/widgets/skeleton_loading_list.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/features/discovery/domain/entities/saved_merchant.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/saved_merchants_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/saved_merchant_card.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/saved_merchants_feedback.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/shop_listings_sheet.dart';

/// The customer's saved shops. Updates as soon as a heart is tapped
/// anywhere in the app; swipe a card left or tap its heart to remove it.
class SavedMerchantsScreen extends StatelessWidget {
  const SavedMerchantsScreen({super.key, required this.discoveryRepository});

  /// Used by "Explore surplus" to load a shop's listings.
  final DiscoveryRepository discoveryRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<SavedMerchantsCubit, SavedMerchantsState>(
          listenWhen: (previous, current) => current.feedback != null,
          listener: showSavedMerchantsFeedback,
          builder: (context, state) {
            final count = state.merchants.length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  subtitle: count == 1
                      ? '1 favourite spot'
                      : '$count favourite spots',
                ),
                Expanded(
                  child: switch (state.status) {
                    SavedMerchantsStatus.signedOut ||
                    SavedMerchantsStatus.loading => const SkeletonLoadingList(),
                    SavedMerchantsStatus.failure => EmptyView(
                      title: 'We could not load your saved shops',
                      message: state.errorMessage,
                    ),
                    SavedMerchantsStatus.ready when count == 0 =>
                      const SkeletonEmptyView(
                        title: 'No saved shops yet',
                        message:
                            'Tap the heart on any food to save its shop here.',
                      ),
                    SavedMerchantsStatus.ready => _SavedList(
                      merchants: state.merchants,
                      discoveryRepository: discoveryRepository,
                    ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.md,
        AppSpacing.pagePadding,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saved collections', style: textTheme.titleLarge),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedList extends StatelessWidget {
  const _SavedList({
    required this.merchants,
    required this.discoveryRepository,
  });

  final List<SavedMerchant> merchants;
  final DiscoveryRepository discoveryRepository;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        0,
        AppSpacing.pagePadding,
        AppSpacing.xl,
      ),
      itemCount: merchants.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.xl - AppSpacing.xs),
      itemBuilder: (context, index) {
        final business = merchants[index].business;
        return StaggeredEntrance(
          index: index,
          child: Dismissible(
            key: ValueKey(business.id),
            direction: DismissDirection.endToStart,
            background: const _RemoveBackground(),
            // The saved list stream drops the card straight away from
            // Firestore's local cache, so the swipe never lingers.
            onDismissed: (_) =>
                context.read<SavedMerchantsCubit>().toggle(business),
            child: SavedMerchantCard(
              business: business,
              onExplore: () => showShopListingsSheet(
                context,
                business: business,
                repository: discoveryRepository,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedDelete02,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Remove',
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
