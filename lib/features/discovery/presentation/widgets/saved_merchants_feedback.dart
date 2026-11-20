import 'package:flutter/widgets.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/features/discovery/presentation/bloc/saved_merchants_cubit.dart';

/// Shows the result of saving or removing a business. Several screens
/// listen to the same app-wide cubit, so only the one on top shows it.
void showSavedMerchantsFeedback(
  BuildContext context,
  SavedMerchantsState state,
) {
  final feedback = state.feedback;
  if (feedback == null) return;
  if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
  if (feedback.isError) {
    AppSnackBar.showError(context, feedback.message);
  } else {
    AppSnackBar.showSuccess(context, feedback.message);
  }
}
