import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';

/// "Continue with Google". Used on both login and register.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthBloc bloc) => bloc.state.isLoading);
    return TapScale(
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isLoading
              ? null
              : () => context.read<AuthBloc>().add(
                  const AuthGoogleLoginRequested(),
                ),
          child: const Text('Continue with Google'),
        ),
      ),
    );
  }
}
