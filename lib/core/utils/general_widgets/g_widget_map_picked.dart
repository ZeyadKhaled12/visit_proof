import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../configs/app_theme.dart';

class GWidgetMapPicked extends StatelessWidget {
  final LatLng? location;
  final VoidCallback? onTap;

  const GWidgetMapPicked({
    super.key,
    this.location,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.iconLightGrey),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: location == null ? _buildPlaceholder() : _buildStaticMap(),
        ),
      ),
    );
  }

  // 2. Improved, cleaner placeholder UI
  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.locationChipBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_rounded,
            size: 26,
            color: AppTheme.primary,
          ),
          SizedBox(width: 12),
          Text(
            "Pick from map".tr,
            style: AppTheme.font(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: AppTheme.textTitle,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Static map using AppTheme for the marker and overlay
  Widget _buildStaticMap() {
    return Stack(
      children: [
        FlutterMap(
          key: ValueKey('${location!.latitude}_${location!.longitude}'),
          options: MapOptions(
            initialCenter: location!,
            initialZoom: 18,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.visit_proof'),
            MarkerLayer(
              markers: [
                Marker(
                  point: location!,
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.location_on,
                    color: AppTheme
                        .primary, // Using your brand's orange for marker
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Optional touch: A small edit badge to indicate it's tappable
        PositionedDirectional(
          end: 8,
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.onPrimary.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 14, color: AppTheme.textPrimary),
                SizedBox(width: 4),
                Text(
                  "Edit".tr,
                  style: AppTheme.font(
                    fontSize: AppTheme.textBodyLarge,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
