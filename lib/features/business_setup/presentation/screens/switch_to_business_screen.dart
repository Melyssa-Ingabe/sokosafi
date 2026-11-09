import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/features/business_setup/data/repositories/firestore_business_repository.dart';
import 'package:sokosafi/features/business_setup/presentation/bloc/owned_business_cubit.dart';
import 'package:sokosafi/router/app_routes.dart';

/// Target of the "Switch to business" button in Settings. Opens business
/// setup when the user has no business yet, otherwise the dashboard.
class SwitchToBusinessScreen extends StatelessWidget {
  const SwitchToBusinessScreen({super.key, required this.ownerId});

  final String ownerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnedBusinessCubit(
        businessRepository: FirestoreBusinessRepository(),
        ownerId: ownerId,
      )..start(),
      child: BlocConsumer<OwnedBusinessCubit, OwnedBusinessState>(
        listenWhen: (previous, current) =>
            current.status == OwnedBusinessStatus.loaded,
        listener: (context, state) {
          if (state.needsSetup) {
            // Replaces this screen, so back from setup returns to Settings.
            context.pushReplacement(AppRoutes.businessSetup);
          } else {
            context.go(AppRoutes.businessHome);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(),
            body: state.status == OwnedBusinessStatus.failure
                ? EmptyView(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedStore01,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    title: 'We could not open your business',
                    message: state.errorMessage,
                    actionLabel: 'Try again',
                    onAction: () => context.read<OwnedBusinessCubit>().start(),
                  )
                : const LoadingView(message: 'Opening your business...'),
          );
        },
      ),
    );
  }
}
