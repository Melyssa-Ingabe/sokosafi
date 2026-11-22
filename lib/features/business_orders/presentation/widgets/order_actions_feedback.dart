import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/features/business_orders/presentation/bloc/order_actions_cubit.dart';

/// Shows a SnackBar after an order is confirmed or cancelled from a row.
class OrderActionsFeedback extends StatelessWidget {
  const OrderActionsFeedback({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderActionsCubit, OrderActionsState>(
      listenWhen: (previous, current) =>
          current.feedback != null && previous.feedback != current.feedback,
      listener: (context, state) {
        final feedback = state.feedback!;
        if (feedback.isError) {
          AppSnackBar.showError(context, feedback.message);
        } else {
          HapticFeedback.mediumImpact();
          AppSnackBar.showSuccess(context, feedback.message);
        }
      },
      child: child,
    );
  }
}
