import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value,
      onChanged: (newValue) {
        HapticFeedback.selectionClick();
        onChanged(newValue);
      },
    );
  }
}
