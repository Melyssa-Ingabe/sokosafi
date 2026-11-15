import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/theme/app_text_styles.dart';

/// Square camera preview that reports every QR code it reads.
class PickupScannerView extends StatelessWidget {
  const PickupScannerView({
    super.key,
    required this.isChecking,
    required this.onCodeScanned,
  });

  final bool isChecking;
  final ValueChanged<String> onCodeScanned;

  void _handleCapture(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        onCodeScanned(value);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              onDetect: _handleCapture,
              errorBuilder: (context, error) => _ScannerError(error: error),
            ),
            if (isChecking)
              ColoredBox(
                color: AppColors.textPrimary.withValues(alpha: 0.6),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final message = error.errorCode == MobileScannerErrorCode.permissionDenied
        ? 'Allow camera access in your phone settings, or type the code below.'
        : 'The camera is not available. Type the code below instead.';
    return ColoredBox(
      color: AppColors.surfaceSubtle,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedCameraOff01,
                size: 40,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
