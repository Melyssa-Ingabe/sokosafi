import 'package:flutter/material.dart';
import 'package:sokosafi/features/auth/presentation/widgets/auth_feedback_listener.dart';
import 'package:sokosafi/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:sokosafi/features/auth/presentation/widgets/forgot_password_form.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthFeedbackListener(
      child: AuthScaffold(
        title: 'Reset your password',
        subtitle: 'Enter your email and we will send you a reset link',
        showBackButton: true,
        children: [ForgotPasswordForm()],
      ),
    );
  }
}
