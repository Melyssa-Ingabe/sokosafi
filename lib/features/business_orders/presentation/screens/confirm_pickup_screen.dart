import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/theme/app_text_styles.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/features/business_orders/data/repositories/firestore_business_orders_repository.dart';
import 'package:sokosafi/features/business_orders/domain/failures/business_orders_failure.dart';
import 'package:sokosafi/features/business_orders/presentation/bloc/confirm_pickup_cubit.dart';
import 'package:sokosafi/features/business_orders/presentation/widgets/manual_code_form.dart';
import 'package:sokosafi/features/business_orders/presentation/widgets/pickup_scanner_view.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/owned_business_gate.dart';

/// Scan or type a customer's pickup code to mark their order collected.
class ConfirmPickupScreen extends StatelessWidget {
  const ConfirmPickupScreen({super.key, required this.ownerId});

  final String ownerId;

  @override
  Widget build(BuildContext context) {
    return OwnedBusinessGate(
      ownerId: ownerId,
      title: 'Confirm pickup',
      builder: (context, business) => BlocProvider(
        create: (_) => ConfirmPickupCubit(
          repository: FirestoreBusinessOrdersRepository(),
          businessId: business.id,
        ),
        child: const _ConfirmPickupView(),
      ),
    );
  }
}

class _ConfirmPickupView extends StatelessWidget {
  const _ConfirmPickupView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm pickup')),
      body: BlocConsumer<ConfirmPickupCubit, ConfirmPickupState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == ConfirmPickupStatus.confirmed) {
            HapticFeedback.mediumImpact();
            AppSnackBar.showSuccess(
              context,
              'Pickup confirmed. The order is now collected',
            );
            Navigator.of(context).maybePop();
          } else if (state.status == ConfirmPickupStatus.failed) {
            AppSnackBar.showError(
              context,
              state.errorMessage ?? BusinessOrdersFailure.genericMessage,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<ConfirmPickupCubit>();
          final isChecking = state.status == ConfirmPickupStatus.checking;
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                // Keeps the camera square a sensible size on large phones
                // and in landscape, where the page scrolls instead.
                constraints: const BoxConstraints(maxWidth: 420),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  children: [
                    Text(
                      "Scan the QR code on the customer's pickup pass",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PickupScannerView(
                      isChecking: isChecking,
                      onCodeScanned: cubit.scan,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Or type the code',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ManualCodeForm(
                      isChecking: isChecking,
                      onSubmit: cubit.confirm,
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
