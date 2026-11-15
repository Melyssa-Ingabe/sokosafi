import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/auth/presentation/widgets/auth_feedback_listener.dart';
import 'package:sokosafi/features/auth/presentation/widgets/auth_scaffold.dart';

/// The app stays blocked here until the user opens the link in their email.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.select((AuthBloc bloc) => bloc.state.user?.email);
    final isLoading = context.select((AuthBloc bloc) => bloc.state.isLoading);
    final authBloc = context.read<AuthBloc>();

    return AuthFeedbackListener(
      child: AuthScaffold(
        title: 'Check your email',
        subtitle:
            'We sent a verification link to ${email ?? 'your email address'}. '
            'Open it, then come back and tap the button below.',
        children: [
          PrimaryButton(
            label: 'I have verified my email',
            isLoading: isLoading,
            onPressed: () => authBloc.add(const AuthVerificationChecked()),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: isLoading
                ? null
                : () => authBloc.add(
                    const AuthVerificationEmailResendRequested(),
                  ),
            child: const Text('Resend verification email'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: isLoading
                ? null
                : () => authBloc.add(const AuthLogoutRequested()),
            child: const Text('Use a different account'),
          ),
        ],
      ),
    );
  }
}
