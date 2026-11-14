import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/utils/validators.dart';
import 'package:sokosafi/core/widgets/app_text_field.dart';
import 'package:sokosafi/core/widgets/password_text_field.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';
import 'package:sokosafi/features/auth/presentation/bloc/auth_bloc.dart';

/// Name, email, phone and password fields. It only holds form controllers;
/// the rules live in Validators and the registration itself in AuthBloc.
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthBloc bloc) => bloc.state.isLoading);
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Full name',
              controller: _nameController,
              validator: Validators.name,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Email',
              controller: _emailController,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Phone number',
              hint: '078 123 4567',
              controller: _phoneController,
              validator: Validators.phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
            const SizedBox(height: AppSpacing.lg),
            PasswordTextField(
              controller: _passwordController,
              validator: Validators.password,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: AppSpacing.lg),
            PasswordTextField(
              label: 'Confirm password',
              controller: _confirmController,
              validator: (value) =>
                  Validators.confirmPassword(value, _passwordController.text),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Create account',
              onPressed: _submit,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
