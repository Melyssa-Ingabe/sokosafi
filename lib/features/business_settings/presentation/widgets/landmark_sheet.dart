import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_text_styles.dart';
import 'package:sokosafi/core/widgets/app_text_field.dart';
import 'package:sokosafi/core/widgets/primary_button.dart';
import 'package:sokosafi/features/business_settings/domain/entities/business_settings.dart';

/// Bottom sheet for typing the pickup landmark. Returns the text when the
/// owner taps Save, or null when they close the sheet.
///
/// Stateful only to own the TextEditingController; saving happens in
/// BusinessSettingsCubit.
class LandmarkSheet extends StatefulWidget {
  const LandmarkSheet({super.key, required this.initialLandmark});

  final String initialLandmark;

  static Future<String?> show(BuildContext context, String initialLandmark) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => LandmarkSheet(initialLandmark: initialLandmark),
    );
  }

  @override
  State<LandmarkSheet> createState() => _LandmarkSheetState();
}

class _LandmarkSheetState extends State<LandmarkSheet> {
  late final _landmarkController = TextEditingController(
    text: widget.initialLandmark,
  );

  @override
  void dispose() {
    _landmarkController.dispose();
    super.dispose();
  }

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
            Text('Pickup landmark', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Something customers can spot when they arrive.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Landmark',
              hint: 'Green awning next to the pharmacy',
              controller: _landmarkController,
              maxLength: BusinessSettings.maxLandmarkLength,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) =>
                  Navigator.of(context).pop(_landmarkController.text),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Save',
              onPressed: () =>
                  Navigator.of(context).pop(_landmarkController.text),
            ),
          ],
        ),
      ),
    );
  }
}
