import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/discovery/data/repositories/url_directions_launcher.dart';
import 'package:sokosafi/features/discovery/domain/repositories/directions_launcher.dart';

/// Opens walking or driving directions to the shop in the maps app.
/// [compact] is an icon-only button for tight rows.
class DirectionsButton extends StatelessWidget {
  const DirectionsButton({
    super.key,
    required this.business,
    this.compact = false,
    this.launcher = const UrlDirectionsLauncher(),
  });

  final Business business;
  final bool compact;
  final DirectionsLauncher launcher;

  static const String failureMessage =
      'We could not open maps on this phone. The address is on this page.';

  Future<void> _open(BuildContext context) async {
    final opened = await launcher.openDirections(
      latitude: business.latitude,
      longitude: business.longitude,
    );
    if (!opened && context.mounted) {
      AppSnackBar.showError(context, failureMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    const icon = HugeIcon(
      icon: HugeIcons.strokeRoundedDirections01,
      size: 18,
      color: AppColors.primary,
    );
    if (compact) {
      return IconButton.outlined(
        tooltip: 'Directions to ${business.name}',
        style: IconButton.styleFrom(
          fixedSize: const Size.square(AppSpacing.minTapTarget),
          side: const BorderSide(color: AppColors.borderSubtle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
        onPressed: () => _open(context),
        icon: icon,
      );
    }
    return SizedBox(
      height: AppSpacing.minTapTarget,
      child: OutlinedButton.icon(
        onPressed: () => _open(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.borderSubtle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
        icon: icon,
        label: const Text('Get directions'),
      ),
    );
  }
}
