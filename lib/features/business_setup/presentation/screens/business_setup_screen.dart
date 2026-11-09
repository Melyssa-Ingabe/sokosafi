import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/constants/animation_constants.dart';
import 'package:sokosafi/core/storage/image_storage.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/features/business_setup/data/repositories/device_location_repository.dart';
import 'package:sokosafi/core/storage/device_photo_picker.dart';
import 'package:sokosafi/features/business_setup/data/repositories/firestore_business_repository.dart';
import 'package:sokosafi/features/business_setup/presentation/bloc/business_setup_bloc.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/details_step.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/location_step.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/photo_step.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/setup_header.dart';
import 'package:sokosafi/router/app_routes.dart';

/// Business Setup 1 to 3 in one screen. The steps slide in and out; the
/// system back gesture goes to the previous step instead of leaving.
class BusinessSetupScreen extends StatelessWidget {
  const BusinessSetupScreen({super.key, required this.ownerId});

  final String ownerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BusinessSetupBloc(
        ownerId: ownerId,
        businessRepository: FirestoreBusinessRepository(),
        locationRepository: DeviceLocationRepository(),
        photoPicker: DevicePhotoPicker(),
        imageStorage: const UnavailableImageStorage(),
      ),
      child: const _BusinessSetupView(),
    );
  }
}

class _BusinessSetupView extends StatelessWidget {
  const _BusinessSetupView();

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.customerHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BusinessSetupBloc>();
    return BlocListener<BusinessSetupBloc, BusinessSetupState>(
      listener: (context, state) {
        final feedback = state.feedback;
        if (feedback != null) {
          feedback.isError
              ? AppSnackBar.showError(context, feedback.message)
              : AppSnackBar.showSuccess(context, feedback.message);
        }
        if (state.status == BusinessSetupStatus.success) {
          context.go(AppRoutes.businessHome);
        }
      },
      child:
          BlocSelector<
            BusinessSetupBloc,
            BusinessSetupState,
            BusinessSetupStep
          >(
            selector: (state) => state.step,
            builder: (context, step) {
              final isFirstStep = step == BusinessSetupStep.details;
              return PopScope(
                canPop: isFirstStep,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) bloc.add(const SetupStepBack());
                },
                child: Scaffold(
                  body: SafeArea(
                    child: Column(
                      children: [
                        SetupHeader(
                          stepNumber: step.number,
                          stepCount: BusinessSetupStep.count,
                          onLeading: isFirstStep
                              ? () => _close(context)
                              : () => bloc.add(const SetupStepBack()),
                        ),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: AnimationConstants.pageTransition,
                            switchInCurve: AnimationConstants.pageCurve,
                            switchOutCurve:
                                AnimationConstants.pageCurve.flipped,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.08, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                ),
                            child: KeyedSubtree(
                              key: ValueKey(step),
                              child: switch (step) {
                                BusinessSetupStep.details =>
                                  const DetailsStep(),
                                BusinessSetupStep.location =>
                                  const LocationStep(),
                                BusinessSetupStep.photo => const PhotoStep(),
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}
