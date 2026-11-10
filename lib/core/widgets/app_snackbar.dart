import 'package:flutter/material.dart';

/// Polite, consistent messages. Every error in the app goes through here,
/// so users never see a raw Firebase error.
abstract final class AppSnackBar {
  static void showError(BuildContext context, String message) {
    _show(context, message, isError: true);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, isError: false);
  }

  static void _show(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    final theme = Theme.of(context);
    final background = isError
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final foreground = isError
        ? theme.colorScheme.onError
        : theme.colorScheme.onPrimary;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          content: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
          ),
        ),
      );
  }
}
