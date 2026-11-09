import 'package:flutter/material.dart';

/// Asks before a listing is deleted. Returns true when the owner confirms.
class DeleteListingDialog extends StatelessWidget {
  const DeleteListingDialog({super.key, required this.title});

  final String title;

  static Future<bool> show(
    BuildContext context, {
    required String title,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteListingDialog(title: title),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Delete this listing?'),
      content: Text(
        'Customers will no longer see "$title". This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: scheme.error),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
