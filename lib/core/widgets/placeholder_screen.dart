import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';

/// Stands in for a screen that its owner has not built yet. Delete the
/// placeholder route once the real screen exists.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.onLogout});

  final String title;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (onLogout != null)
            TextButton(onPressed: onLogout, child: const Text('Log out')),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            '$title will replace this placeholder.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
