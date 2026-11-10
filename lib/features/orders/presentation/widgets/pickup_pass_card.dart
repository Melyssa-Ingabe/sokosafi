import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/widgets/app_snackbar.dart';

/// QR code and readable code the business checks at pickup.
class PickupPassCard extends StatelessWidget {
  const PickupPassCard({super.key, required this.pickupCode});

  final String pickupCode;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: pickupCode));
    await HapticFeedback.lightImpact();
    if (context.mounted) AppSnackBar.showSuccess(context, 'Pickup code copied');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            // Scanners need dark modules on a light background, so the code
            // stays black on white even in dark mode.
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              ),
              child: QrImageView(
                data: pickupCode,
                size: 180,
                padding: const EdgeInsets.all(AppSpacing.md),
                semanticsLabel: 'Pickup QR code',
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.textPrimary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'MANUAL VERIFICATION CODE',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SelectableText(pickupCode, style: theme.textTheme.headlineMedium),
            TextButton.icon(
              onPressed: () => _copy(context),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedCopy01,
                color: theme.colorScheme.primary,
                size: 18,
              ),
              label: const Text('Copy code'),
            ),
          ],
        ),
      ),
    );
  }
}
