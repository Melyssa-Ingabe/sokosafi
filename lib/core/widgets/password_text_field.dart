import 'package:flutter/material.dart';
import 'package:sokosafi/core/widgets/app_text_field.dart';

/// Password field with a Show/Hide toggle. The toggle uses a ValueNotifier
/// instead of setState.
class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    this.label = 'Password',
    this.controller,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  final ValueNotifier<bool> _isHidden = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _isHidden.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isHidden,
      builder: (context, isHidden, _) {
        return AppTextField(
          label: widget.label,
          controller: widget.controller,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          autofillHints: widget.autofillHints,
          obscureText: isHidden,
          suffix: TextButton(
            onPressed: () => _isHidden.value = !isHidden,
            child: Text(isHidden ? 'Show' : 'Hide'),
          ),
        );
      },
    );
  }
}
