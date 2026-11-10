import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/menu_group.dart';
import 'package:sokosafi/core/widgets/menu_tile.dart';
import 'package:sokosafi/core/widgets/staggered_entrance.dart';
import 'package:sokosafi/core/widgets/start_selling_card.dart';
import 'package:sokosafi/features/auth/domain/entities/app_user.dart';
import 'package:sokosafi/features/auth/domain/entities/user_role.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/settings/presentation/widgets/preferences_group.dart';
import 'package:sokosafi/router/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in at any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay signed in'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) authBloc.add(const AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, AppUser?>((bloc) => bloc.state.user);
    final sections = <Widget>[
      MenuGroup(
        title: 'Account',
        children: [
          MenuTile(
            icon: HugeIcons.strokeRoundedUserEdit01,
            title: 'Edit profile',
            onTap: () => context.push(AppRoutes.editProfile),
          ),
          MenuTile(
            icon: HugeIcons.strokeRoundedCall,
            title: 'Phone number',
            value: (user?.phone.isEmpty ?? true) ? 'Not set' : user!.phone,
          ),
          MenuTile(
            icon: HugeIcons.strokeRoundedSquareLock02,
            title: 'Change password',
            onTap: user == null
                ? null
                : () => context.read<AuthBloc>().add(
                    AuthPasswordResetRequested(user.email),
                  ),
          ),
        ],
      ),
      const PreferencesGroup(),
      if (user?.role == UserRole.customer)
        StartSellingCard(onTap: () => context.push(AppRoutes.switchToBusiness)),
      MenuGroup(
        children: [
          MenuTile(
            icon: HugeIcons.strokeRoundedLogout01,
            title: 'Sign out',
            isDestructive: true,
            onTap: () => _confirmSignOut(context),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current.feedback != null && previous.feedback != current.feedback,
        listener: (context, state) {
          final feedback = state.feedback!;
          if (feedback.isError) {
            AppSnackBar.showError(context, feedback.message);
          } else {
            AppSnackBar.showSuccess(context, feedback.message);
          }
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          itemCount: sections.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xl),
          itemBuilder: (context, index) =>
              StaggeredEntrance(index: index, child: sections[index]),
        ),
      ),
    );
  }
}
