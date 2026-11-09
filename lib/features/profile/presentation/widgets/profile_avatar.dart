import 'package:flutter/material.dart';

/// The profile photo, or the person's initials when there is none.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    required this.photoUrl,
    this.radius = 44,
  });

  final String name;
  final String photoUrl;
  final double radius;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhoto = photoUrl.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      foregroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
      child: Text(
        _initials,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
