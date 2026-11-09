import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/utils/validators.dart';
import 'package:sokosafi/core/widgets/app_text_field.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';

/// Stateful only to own the form key and text controllers.
class EditProfileForm extends StatefulWidget {
  const EditProfileForm({
    super.key,
    required this.initialName,
    required this.initialPhone,
    required this.email,
    required this.isSaving,
    required this.onSave,
  });

  final String initialName;
  final String initialPhone;
  final String email;
  final bool isSaving;
  final void Function(String name, String phone) onSave;

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialName,
  );
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.initialPhone,
  );
  late final TextEditingController _emailController = TextEditingController(
    text: widget.email,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(_nameController.text, _phoneController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          AppTextField(
            label: 'Full name',
            controller: _nameController,
            validator: Validators.name,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Phone number',
            hint: '078 123 4567',
            controller: _phoneController,
            validator: Validators.phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumber],
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Email',
            controller: _emailController,
            enabled: false,
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: 'Save changes',
            isLoading: widget.isSaving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
