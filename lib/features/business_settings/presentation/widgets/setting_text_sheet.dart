import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_text_styles.dart';
import 'package:sokosafi/core/widgets/app_text_field.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';

/// Bottom sheet for typing one business setting, such as the pickup
/// landmark or the store phone. Returns the text when the owner taps Save,
/// or null when they close the sheet.
///
/// Stateful only to own the TextEditingController; saving happens in
/// BusinessSettingsCubit.
class SettingTextSheet extends StatefulWidget {
  const SettingTextSheet({
    super.key,
    required this.title,
    required this.description,
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.maxLength,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final String title;
  final String description;
  final String label;
  final String hint;
  final String initialValue;
  final int maxLength;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      // Above the shell, so the floating nav bar never covers the sheet.
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => this,
    );
  }

  @override
  State<SettingTextSheet> createState() => _SettingTextSheetState();
}

class _SettingTextSheetState extends State<SettingTextSheet> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    // Lifts the sheet above the keyboard.
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        0,
        AppSpacing.pagePadding,
        AppSpacing.pagePadding + keyboardHeight,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            Text(widget.description, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: widget.label,
              hint: widget.hint,
              controller: _controller,
              maxLength: widget.maxLength,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Save', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
