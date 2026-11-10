import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';
import 'package:sokosafi/features/business_setup/presentation/bloc/business_setup_bloc.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/map_pin.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/map_zoom_buttons.dart';

/// OpenStreetMap view with a fixed pin in the middle. The owner moves the
/// map under the pin; when the map stops, the center is sent to the BLoC.
/// Stateful only to own the MapController.
class LocationMap extends StatefulWidget {
  const LocationMap({super.key});

  /// Kigali city center, shown until a location is chosen.
  static const LatLng kigali = LatLng(-1.9441, 30.0619);
  static const double defaultZoom = 16;

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onMapEvent(MapEvent event) {
    // Moves made by the app itself (GPS, search, zoom buttons) are not the
    // owner choosing a spot, so only gesture-driven stops are reported.
    final isGestureStop =
        event is MapEventMoveEnd ||
        event is MapEventFlingAnimationEnd ||
        event is MapEventDoubleTapZoomEnd;
    if (!isGestureStop || event.source == MapEventSource.mapController) return;
    final center = event.camera.center;
    context.read<BusinessSetupBloc>().add(
      MapPinMoved(latitude: center.latitude, longitude: center.longitude),
    );
  }

  void _zoomBy(double change) {
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom + change);
  }

  @override
  Widget build(BuildContext context) {
    final initialState = context.read<BusinessSetupBloc>().state;
    final latitude = initialState.latitude;
    final longitude = initialState.longitude;
    final initialCenter = latitude != null && longitude != null
        ? LatLng(latitude, longitude)
        : LocationMap.kigali;

    return BlocListener<BusinessSetupBloc, BusinessSetupState>(
      listenWhen: (previous, current) =>
          previous.mapFocusRevision != current.mapFocusRevision,
      listener: (context, state) {
        final newLatitude = state.latitude;
        final newLongitude = state.longitude;
        if (newLatitude == null || newLongitude == null) return;
        _mapController.move(
          LatLng(newLatitude, newLongitude),
          LocationMap.defaultZoom,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.brandSubtle),
          child: Stack(
            alignment: Alignment.center,
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: LocationMap.defaultZoom,
                  minZoom: 5,
                  maxZoom: 19,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                  onMapEvent: _onMapEvent,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sokosafi.sokosafi',
                  ),
                  // Credit required by the OpenStreetMap tile licence.
                  const SimpleAttributionWidget(
                    source: Text('OpenStreetMap contributors'),
                  ),
                ],
              ),
              const MapPin(),
              Positioned(
                right: AppSpacing.md,
                bottom: AppSpacing.xxl,
                child: MapZoomButtons(
                  onZoomIn: () => _zoomBy(1),
                  onZoomOut: () => _zoomBy(-1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
