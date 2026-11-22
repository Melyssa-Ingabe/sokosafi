import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/core/widgets/tap_scale.dart';
import 'package:sokosafi/features/discovery/data/repositories/url_directions_launcher.dart';
import 'package:sokosafi/features/discovery/data/repositories/url_phone_launcher.dart';
import 'package:sokosafi/features/discovery/domain/repositories/directions_launcher.dart';
import 'package:sokosafi/features/discovery/domain/repositories/phone_launcher.dart';

/// Directions and Call store side by side. Call store only shows once the
/// shop has saved a phone number in its settings.
class StoreContactButtons extends StatelessWidget {
  const StoreContactButtons({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.directionsLauncher = const UrlDirectionsLauncher(),
    this.phoneLauncher = const UrlPhoneLauncher(),
  });

  final double latitude;
  final double longitude;

  /// Call store is hidden when this is empty.
  final String phone;
  final DirectionsLauncher directionsLauncher;
  final PhoneLauncher phoneLauncher;

  static const String directionsFailure =
      'We could not open maps on this phone.';
  static const String callFailure =
      'This phone cannot make calls. The number is in the shop details.';

  Future<void> _openDirections(BuildContext context) async {
    final opened = await directionsLauncher.openDirections(
      latitude: latitude,
      longitude: longitude,
    );
    if (!opened && context.mounted) {
      AppSnackBar.showError(context, directionsFailure);
    }
  }

  Future<void> _call(BuildContext context) async {
    final opened = await phoneLauncher.call(phone);
    if (!opened && context.mounted) {
      AppSnackBar.showError(context, callFailure);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ContactButton(
            icon: HugeIcons.strokeRoundedDirections01,
            label: 'Directions',
            onPressed: () => _openDirections(context),
          ),
        ),
        if (phone.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _ContactButton(
              icon: HugeIcons.strokeRoundedCall,
              label: 'Call store',
              onPressed: () => _call(context),
            ),
          ),
        ],
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TapScale(
      child: SizedBox(
        height: AppSpacing.minTapTarget,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: scheme.primary,
            side: BorderSide(color: scheme.outlineVariant),
            shape: const StadiumBorder(),
          ),
          icon: HugeIcon(icon: icon, size: 18, color: scheme.primary),
          label: Text(label),
        ),
      ),
    );
  }
}
