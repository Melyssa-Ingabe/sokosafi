import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/features/business_setup/data/repositories/firestore_business_repository.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/business_setup/presentation/bloc/owned_business_cubit.dart';
import 'package:sokosafi/router/app_routes.dart';

/// Loads the signed-in owner's business and builds [builder] with it. Shows
/// loading, a retry on error, and a way into setup when there is no business
/// yet. Used by every screen that needs a businessId.
class OwnedBusinessGate extends StatelessWidget {
  const OwnedBusinessGate({
    super.key,
    required this.ownerId,
    required this.title,
    required this.builder,
  });

  final String ownerId;

  /// App bar title while the business is loading or missing.
  final String title;
  final Widget Function(BuildContext context, Business business) builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnedBusinessCubit(
        businessRepository: FirestoreBusinessRepository(),
        ownerId: ownerId,
      )..start(),
      child: BlocBuilder<OwnedBusinessCubit, OwnedBusinessState>(
        // Only the first load matters here; screens below follow their own
        // streams, so a business update must not rebuild them from scratch.
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.business?.id != current.business?.id,
        builder: (context, state) {
          final business = state.business;
          if (business != null) return builder(context, business);

          final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: switch (state.status) {
              OwnedBusinessStatus.loading => const LoadingView(),
              OwnedBusinessStatus.failure => EmptyView(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedStore01,
                  size: 48,
                  color: iconColor,
                ),
                title: 'We could not open your business',
                message: state.errorMessage,
                actionLabel: 'Try again',
                onAction: () => context.read<OwnedBusinessCubit>().start(),
              ),
              OwnedBusinessStatus.loaded => EmptyView(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedStore01,
                  size: 48,
                  color: iconColor,
                ),
                title: 'Set up your business first',
                message: 'Listings belong to a business. It takes a minute.',
                actionLabel: 'Set up my business',
                onAction: () => context.push(AppRoutes.businessSetup),
              ),
            },
          );
        },
      ),
    );
  }
}
