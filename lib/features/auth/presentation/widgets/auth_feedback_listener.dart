import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';

/// Shows each new AuthBloc message as a SnackBar. Wrap every auth screen in it.
class AuthFeedbackListener extends StatelessWidget {
  const AuthFeedbackListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.feedback != current.feedback && current.feedback != null,
      listener: (context, state) {
        final feedback = state.feedback;
        if (feedback == null) return;
        if (feedback.isError) {
          AppSnackBar.showError(context, feedback.message);
        } else {
          AppSnackBar.showSuccess(context, feedback.message);
        }
      },
      child: child,
    );
  }
}
