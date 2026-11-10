import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/empty_view.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/orders/presentation/cubit/checkout_cubit.dart';
import 'package:sokosafi/features/orders/presentation/widgets/checkout_form.dart';
import 'package:sokosafi/router/app_routes.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = context.select<AuthBloc, String>(
      (bloc) => bloc.state.user?.phone ?? '',
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listenWhen: (previous, current) =>
            previous.placedOrderId != current.placedOrderId ||
            (previous.isSubmitting && current.errorMessage != null),
        listener: (context, state) {
          final orderId = state.placedOrderId;
          if (orderId != null) {
            HapticFeedback.mediumImpact();
            context.pushReplacement(AppRoutes.orderFor(orderId));
          } else if (state.errorMessage != null) {
            AppSnackBar.showError(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          return switch (state.status) {
            CheckoutStatus.loading => const LoadingView(
              message: 'Loading your bag',
            ),
            CheckoutStatus.failure => EmptyView(
              title: 'We could not open checkout',
              message: state.errorMessage,
              actionLabel: 'Try again',
              onAction: context.read<CheckoutCubit>().load,
            ),
            CheckoutStatus.ready => CheckoutForm(state: state, phone: phone),
          };
        },
      ),
    );
  }
}
