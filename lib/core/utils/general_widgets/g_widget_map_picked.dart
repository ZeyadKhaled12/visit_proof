import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';

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
        color: AppColors.surfaceWhite,
        border: Border.all(color: AppColors.iconLightGrey),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
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
      color: AppColors.locationChipBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_rounded,
            size: 26,
            color: AppColors.primary,
          ),
          SizedBox(width: 12),
          Text(
            "Pick from map",
            style: AppFonts(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Static map using AppColors for the marker and overlay
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
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors
                        .primary, // Using your brand's orange for marker
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Optional touch: A small edit badge to indicate it's tappable
        Positioned(
          right: 8,
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 14, color: AppColors.textPrimary),
                SizedBox(width: 4),
                Text(
                  "Edit",
                  style: AppFonts(
                    fontSize: 14,
                    color: AppColors.textPrimary,
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
