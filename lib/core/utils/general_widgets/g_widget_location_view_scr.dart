import 'package:visit_proof/configs/app_tours.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import '../../../configs/app_theme.dart';

/// Displays an immutable geographic location while allowing the camera to move.
///
/// The destination marker is fixed to [latitude] and [longitude]. Panning or
/// zooming the map never changes the destination or the address shown below.
class GWidgetLocationViewScr extends StatefulWidget {
  const GWidgetLocationViewScr({
    super.key,
    required this.latitude,
    required this.longitude,
  })  : assert(latitude >= -90 && latitude <= 90, 'Invalid latitude'),
        assert(longitude >= -180 && longitude <= 180, 'Invalid longitude');

  final double latitude;
  final double longitude;

  @override
  State<GWidgetLocationViewScr> createState() => _GWidgetLocationViewScrState();
}

class _GWidgetLocationViewScrState extends State<GWidgetLocationViewScr> {
  static const double _initialZoom = 16;

  final MapController _mapController = MapController();

  late LatLng _location;
  late String _address;
  bool _mapReady = false;
  int _addressRequest = 0;

  String get _coordinatesLabel => '${widget.latitude.toStringAsFixed(6)}, '
      '${widget.longitude.toStringAsFixed(6)}';

  @override
  void initState() {
    super.initState();
    _location = LatLng(widget.latitude, widget.longitude);
    _address = _coordinatesLabel;
    _loadAddress();
  }

  @override
  void didUpdateWidget(covariant GWidgetLocationViewScr oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.latitude == widget.latitude &&
        oldWidget.longitude == widget.longitude) {
      return;
    }

    // Update only when the parent passes NEW coordinates, never on map gestures.
    _location = LatLng(widget.latitude, widget.longitude);
    _address = _coordinatesLabel;
    _loadAddress();

    if (_mapReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _mapReady) {
          _mapController.move(_location, _initialZoom);
        }
      });
    }
  }

  Future<void> _loadAddress() async {
    final request = ++_addressRequest;
    final latitude = widget.latitude;
    final longitude = widget.longitude;

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (!mounted || request != _addressRequest) return;

      if (placemarks.isEmpty) return;

      final place = placemarks.first;
      final address = <String?>[
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ]
          .whereType<String>()
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toSet()
          .join(', ');

      if (address.isNotEmpty) {
        setState(() => _address = address);
      }
    } catch (error) {
      // Coordinates remain visible if reverse geocoding is unavailable.
      debugPrint('Location address error: $error');
    }
  }

  void _recenterMap() {
    if (!_mapReady) return;
    _mapController.move(_location, _initialZoom);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GWidgetTourFlag(tour: AppTours.locationView, top: 16, child: Scaffold(
      backgroundColor: AppTheme.textPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            GTourTarget(id: 'map', child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _location,
                initialZoom: _initialZoom,
                minZoom: 3,
                maxZoom: 19,
                onMapReady: () => _mapReady = true,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  // Use your real Android/iOS app package identifier in production.
                  userAgentPackageName: 'com.example.visit_proof',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _location,
                      width: 56,
                      height: 56,
                      alignment: Alignment.bottomCenter,
                      child: IgnorePointer(
                        child: Icon(
                          Icons.location_on_rounded,
                          color: AppTheme.primary,
                          size: 48,
                        ),
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'.tr),
                  ],
                ),
              ],
            )),

            // Same floating back button and pill styling as your picker.
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Material(
                    color: AppTheme.surface,
                    elevation: 3,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: AppTheme.textPrimary),
                      onPressed: () => Navigator.pop(context, null),
                    ),
                  ),
                ],
              ),
            ),

            // Moves only the CAMERA back to the marker, not the marker itself.
            GTourTarget(id: 'recenter', child: PositionedDirectional(
              bottom: 220,
              end: 16,
              child: Material(
                color: AppTheme.surface,
                elevation: 3,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Recenter map'.tr,
                  icon: Icon(
                    Icons.center_focus_strong,
                    color: AppTheme.primary,
                  ),
                  onPressed: _recenterMap,
                ),
              ),
            )),

            // Bottom card: read-only address and coordinates; no confirm button.
            GTourTarget(id: 'details', child: Positioned(
              left: 16,
              right: 16,
              bottom: 40,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.iconLightGrey),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location'.tr,
                      style: AppTheme.font(
                        fontSize: AppTheme.textSmall,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.place,
                          size: 20,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.font(
                              color: AppTheme.textPrimary,
                              fontSize: AppTheme.textTitle,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    ));
  }
}
