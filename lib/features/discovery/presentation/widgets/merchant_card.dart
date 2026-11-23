import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/core/utils/date_formatters.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business.dart';
import 'package:sokosafi/features/discovery/presentation/widgets/directions_button.dart';

/// Where to collect the food, from the Merchant card in Figma: a small map
/// with the shop pinned, the address, until when it hands out pickups and
/// a button that opens directions in the maps app.
class MerchantCard extends StatelessWidget {
  const MerchantCard({super.key, required this.business, required this.now});

  final Business business;
  final DateTime now;

  static const double _radius = 16;
  static const double _mapHeight = 112;
  static const double _mapZoom = 16;
  static const double _padding = 14;

  /// "8:00 PM" from the stored "20:00"; the raw value if it is malformed.
  String _pickupEndLabel() {
    final parts = business.pickupEnd.split(':');
    final hour = int.tryParse(parts.first);
    final minute = parts.length > 1 ? int.tryParse(parts[1]) : null;
    if (hour == null || minute == null) return business.pickupEnd;
    return DateFormatters.time(
      DateTime(now.year, now.month, now.day, hour, minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final landmark = business.landmark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _mapHeight,
              // A preview only: gestures are off so the page scrolls normally.
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(business.latitude, business.longitude),
                  initialZoom: _mapZoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sokosafi.sokosafi',
                  ),
                  const Center(child: _ShopPin()),
                  // Credit required by the OpenStreetMap tile licence.
                  // flutter_map's SimpleAttributionWidget is one unbreakable
                  // row that overflows this narrow card on small phones, so
                  // the credit is a corner label that shrinks to fit.
                  const _MapCredit(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(_padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.address,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (landmark.isNotEmpty)
                    Text(
                      landmark,
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox.square(dimension: 6),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Open until ${_pickupEndLabel()} today',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: DirectionsButton(business: business),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCredit extends StatelessWidget {
  const _MapCredit();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        color: AppColors.surface.withValues(alpha: 0.8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '© OpenStreetMap contributors',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ),
    );
  }
}

/// The green store pin in the middle of the map.
class _ShopPin extends StatelessWidget {
  const _ShopPin();

  static const double _size = 36;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surface, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedStore01,
          size: 16,
          color: AppColors.surface,
        ),
      ),
    );
  }
}
