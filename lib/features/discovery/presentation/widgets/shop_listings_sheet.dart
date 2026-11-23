import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/utils/date_formatters.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/skeleton_empty_view.dart';
import 'package:sokosafi/core/widgets/skeleton_loading_list.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/shop_listings_cubit.dart';
import 'package:sokosafi/router/app_routes.dart';

/// Opens the bottom sheet with the food [business] has on sale right now.
Future<void> showShopListingsSheet(
  BuildContext context, {
  required Business business,
  required DiscoveryRepository repository,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => BlocProvider(
      create: (_) =>
          ShopListingsCubit(repository: repository, business: business)
            ..watch(),
      child: ShopListingsSheet(businessName: business.name),
    ),
  );
}

class ShopListingsSheet extends StatelessWidget {
  const ShopListingsSheet({super.key, required this.businessName});

  final String businessName;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.6;
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
            ),
            child: Text(
              'On sale at $businessName',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: BlocBuilder<ShopListingsCubit, ShopListingsState>(
              builder: (context, state) => switch (state.status) {
                ShopListingsStatus.loading => const SkeletonLoadingList(
                  rowCount: 3,
                ),
                ShopListingsStatus.failure => EmptyView(
                  title: 'We could not load this shop',
                  message: state.errorMessage,
                  actionLabel: 'Try again',
                  onAction: context.read<ShopListingsCubit>().watch,
                ),
                ShopListingsStatus.ready when state.items.isEmpty =>
                  const SkeletonEmptyView(
                    title: 'Nothing on sale right now',
                    message:
                        'New food from this shop shows up here and in '
                        'your feed as soon as it is listed.',
                  ),
                ShopListingsStatus.ready => ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  itemCount: state.items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) =>
                      _ShopListingTile(item: state.items[index]),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopListingTile extends StatelessWidget {
  const _ShopListingTile({required this.item});

  final FeedItem item;

  static const double _thumbSize = 56;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final listing = item.listing;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          context.push(AppRoutes.listingFor(listing.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                child: SizedBox.square(
                  dimension: _thumbSize,
                  child: listing.imageUrl.isEmpty
                      ? ColoredBox(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        )
                      : Image.network(
                          listing.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              ColoredBox(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                              ),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Until ${DateFormatters.time(listing.pickupBy)} · '
                      '${listing.quantity} left',
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                Formatters.rwf(listing.discountPrice),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
