import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/app_text_field.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';

/// Field for typing the pickup code when the QR cannot be scanned.

class ManualCodeForm extends StatefulWidget {
  const ManualCodeForm({
    super.key,
    required this.isChecking,
    required this.onSubmit,
  });

  final bool isChecking;
  final ValueChanged<String> onSubmit;

  @override
  State<ManualCodeForm> createState() => _ManualCodeFormState();
}

class _ManualCodeFormState extends State<ManualCodeForm> {
  final _codeController = TextEditingController();

  void _submit() {
    FocusScope.of(context).unfocus();
    widget.onSubmit(_codeController.text);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Pickup code',
          hint: 'SKS-4A7F2B',
          controller: _codeController,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          enabled: !widget.isChecking,
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Confirm pickup',
          isLoading: widget.isChecking,
          onPressed: widget.isChecking ? null : _submit,
        ),
      ],
    );
  }
}
