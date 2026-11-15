import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/features/auth/presentation/widgets/auth_feedback_listener.dart';
import 'package:sokosafi/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:sokosafi/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:sokosafi/features/auth/presentation/widgets/or_divider.dart';
import 'package:sokosafi/features/auth/presentation/widgets/register_form.dart';
import 'package:sokosafi/router/app_routes.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFeedbackListener(
      child: AuthScaffold(
        title: 'Create your account',
        subtitle: 'Join SokoSafi to buy or sell surplus food',
        showBackButton: true,
        children: [
          const RegisterForm(),
          const SizedBox(height: AppSpacing.lg),
          const OrDivider(),
          const SizedBox(height: AppSpacing.lg),
          const GoogleSignInButton(),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Log in'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
