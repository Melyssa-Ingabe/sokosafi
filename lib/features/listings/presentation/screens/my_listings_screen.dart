import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/core/widgets/staggered_fade_in.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/owned_business_gate.dart';
import 'package:sokosafi/features/listings/data/repositories/firestore_listing_repository.dart';
import 'package:sokosafi/features/listings/domain/entities/listing.dart';
import 'package:sokosafi/features/listings/presentation/bloc/listing_bloc.dart';
import 'package:sokosafi/features/listings/presentation/widgets/delete_listing_dialog.dart';
import 'package:sokosafi/features/listings/presentation/widgets/managed_listing_card.dart';
import 'package:sokosafi/router/app_routes.dart';

/// "My active listings": every listing of the owner's business, live from
/// Firestore, with edit and delete.
class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key, required this.ownerId});

  final String ownerId;

  @override
  Widget build(BuildContext context) {
    return OwnedBusinessGate(
      ownerId: ownerId,
      title: 'My listings',
      builder: (context, business) => BlocProvider(
        create: (_) =>
            ListingBloc(listingRepository: FirestoreListingRepository())
              ..add(ListingsSubscriptionRequested(business.id)),
        child: const _MyListingsView(),
      ),
    );
  }
}

class _MyListingsView extends StatelessWidget {
  const _MyListingsView();

  Future<void> _confirmDelete(BuildContext context, Listing listing) async {
    final bloc = context.read<ListingBloc>();
    final confirmed = await DeleteListingDialog.show(
      context,
      title: listing.title,
    );
    if (confirmed) bloc.add(ListingDeleteRequested(listing.id));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('My listings')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createListing),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedAdd01,
          color: scheme.onPrimary,
        ),
        label: const Text('New listing'),
      ),
      body: BlocConsumer<ListingBloc, ListingState>(
        listenWhen: (previous, current) => current.feedback != null,
        listener: (context, state) {
          final feedback = state.feedback!;
          feedback.isError
              ? AppSnackBar.showError(context, feedback.message)
              : AppSnackBar.showSuccess(context, feedback.message);
        },
        builder: (context, state) {
          final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
          switch (state.status) {
            case ListingsStatus.loading:
              return const LoadingView(message: 'Loading your listings...');
            case ListingsStatus.failure:
              return EmptyView(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedWifiError01,
                  size: 48,
                  color: iconColor,
                ),
                title: 'We could not load your listings',
                message: state.errorMessage,
                actionLabel: 'Try again',
                onAction: () => context.read<ListingBloc>().add(
                  ListingsSubscriptionRequested(state.businessId),
                ),
              );
            case ListingsStatus.success when state.listings.isEmpty:
              return EmptyView(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedPackage,
                  size: 48,
                  color: iconColor,
                ),
                title: 'No listings yet',
                message: 'Post your surplus food and nearby customers can reserve it.',
                actionLabel: 'Create a listing',
                onAction: () => context.push(AppRoutes.createListing),
              );
            case ListingsStatus.success:
              final now = DateTime.now();
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  AppSpacing.lg,
                  AppSpacing.pagePadding,
                  // Leaves room so the last card is not hidden under the
                  // floating button.
                  96,
                ),
                itemCount: state.listings.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final listing = state.listings[index];
                  return StaggeredFadeIn(
                    key: ValueKey(listing.id),
                    index: index,
                    child: ManagedListingCard(
                      listing: listing,
                      status: listing.effectiveStatus(now),
                      isDeleting: state.deletingIds.contains(listing.id),
                      onEdit: () =>
                          context.push(AppRoutes.editListing, extra: listing),
                      onDelete: () => _confirmDelete(context, listing),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
