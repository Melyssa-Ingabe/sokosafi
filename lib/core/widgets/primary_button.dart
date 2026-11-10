import 'package:flutter/material.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';

/// Main call-to-action button. Shows a spinner and ignores taps while loading.
/// Set expanded to false when placing it inside a Row.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final button = FilledButton(
      // A no-op keeps the enabled colors while loading instead of turning grey.
      onPressed: isLoading ? () {} : onPressed,
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.onPrimary,
              ),
            )
          : Text(label),
    );
    return TapScale(
      child: expanded
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}
