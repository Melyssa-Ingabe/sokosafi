import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/utils/formatters.dart';
import 'package:sokosafi/core/widgets/app_badge.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/core/widgets/now_ticker.dart';
import 'package:sokosafi/core/widgets/quantity_stepper.dart';
import 'package:sokosafi/features/discovery/domain/entities/feed_item.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/product_detail_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/saved_merchants_cubit.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/merchant_card.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/pickup_times_card.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/product_photo_header.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/reserve_bar.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/save_merchant_button.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/saved_merchants_feedback.dart';
import 'package:sokosafi/router/app_routes.dart';

/// One listing in full: photo, price, pickup times, the shop, and a
/// quantity to reserve.
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, this.heroTag});

  /// Matches the card the customer tapped, so its photo flies in.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SavedMerchantsCubit, SavedMerchantsState>(
      listenWhen: (previous, current) => current.feedback != null,
      listener: (context, state) => showSavedMerchantsFeedback(context, state),
      child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          final item = state.item;
          if (state.status == ProductDetailStatus.failure || item == null) {
            return Scaffold(
              appBar: AppBar(),
              body: state.status == ProductDetailStatus.failure
                  ? EmptyView(
                      title: 'This food is not available',
                      message: state.errorMessage,
                      actionLabel: 'Back to the feed',
                      onAction: () => context.go(AppRoutes.customerHome),
                    )
                  : const LoadingView(),
            );
          }
          // Re-checks every 30 seconds so Reserve turns off when the pick-up
          // time passes while the screen is open.
          return NowTicker(
            builder: (context, now) => Scaffold(
              body: _DetailBody(
                item: item,
                state: state,
                heroTag: heroTag,
                now: now,
              ),
              bottomNavigationBar: ReserveBar(
                quantity: state.quantity,
                total: state.total,
                onReserve: state.canReserveAt(now)
                    ? () => context.push(
                        AppRoutes.checkoutFor(
                          item.listing.id,
                          quantity: state.quantity,
                        ),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.item,
    required this.state,
    required this.heroTag,
    required this.now,
  });

  final FeedItem item;
  final ProductDetailState state;
  final Object? heroTag;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final listing = item.listing;
    final cubit = context.read<ProductDetailCubit>();
    final percentOff = Formatters.discountPercent(
      original: listing.originalPrice,
      discounted: listing.discountPrice,
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        ProductPhotoHeader(
          imageUrl: listing.imageUrl,
          heroTag: heroTag,
          action: SaveMerchantButton(business: item.business),
        ),
        Padding(
          // 20px sides, as in the Product Detail frame in Figma.
          padding: const EdgeInsets.fromLTRB(20, AppSpacing.lg, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(listing.title, style: theme.textTheme.titleLarge),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          listing.quantity > 0
                              ? '${listing.quantity} left'
                              : 'Sold out',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: listing.quantity > 0
                                ? scheme.onSurfaceVariant
                                : scheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  QuantityStepper(
                    quantity: state.quantity,
                    onIncrease: state.canIncrease
                        ? cubit.increaseQuantity
                        : null,
                    onDecrease: state.canDecrease
                        ? cubit.decreaseQuantity
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    Formatters.rwf(listing.discountPrice),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                  Text(
                    Formatters.rwf(listing.originalPrice),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  if (percentOff > 0) AppBadge(label: '-$percentOff%'),
                ],
              ),
              if (listing.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(listing.description, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: AppSpacing.lg),
              PickupTimesCard(
                madeAt: listing.madeAt,
                pickupBy: listing.pickupBy,
                now: now,
              ),
              if (listing.instructions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  listing.instructions,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg + AppSpacing.xs),
              Text(
                'Merchant',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              MerchantCard(business: item.business, now: now),
            ],
          ),
        ),
      ],
    );
  }
}
