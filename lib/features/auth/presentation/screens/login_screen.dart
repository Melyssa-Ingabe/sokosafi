import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/features/auth/presentation/widgets/auth_feedback_listener.dart';
import 'package:sokosafi/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:sokosafi/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:sokosafi/features/auth/presentation/widgets/login_form.dart';
import 'package:sokosafi/router/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFeedbackListener(
      child: AuthScaffold(
        title: 'Welcome back',
        subtitle: 'Log in to find surplus food near you',
        children: [
          const LoginForm(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('or', style: Theme.of(context).textTheme.bodySmall),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const GoogleSignInButton(),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.register),
                child: const Text('Register'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
