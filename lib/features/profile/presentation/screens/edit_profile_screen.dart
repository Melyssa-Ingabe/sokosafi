import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/loading_view.dart';
import 'package:sokosafi/features/auth/domain/entities/app_user.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sokosafi/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:sokosafi/features/profile/presentation/widgets/edit_profile_form.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: BlocListener<EditProfileCubit, EditProfileState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == EditProfileStatus.saved) {
            AppSnackBar.showSuccess(context, 'Profile updated');
            context.pop();
          } else if (state.status == EditProfileStatus.failure) {
            AppSnackBar.showError(
              context,
              state.errorMessage ?? 'We could not save your profile',
            );
          }
        },
        child: user == null ? const LoadingView() : _Form(user: user),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select<EditProfileCubit, bool>(
      (cubit) => cubit.state.status == EditProfileStatus.saving,
    );
    return EditProfileForm(
      initialName: user.name,
      initialPhone: user.phone,
      email: user.email,
      isSaving: isSaving,
      onSave: (name, phone) =>
          context.read<EditProfileCubit>().save(name: name, phone: phone),
    );
  }
}
