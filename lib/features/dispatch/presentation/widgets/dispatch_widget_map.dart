import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/general_widgets/g_widget_empty.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import 'dispatch_widget_action_sheet.dart';
import 'sheets/dispatch_widget_visit_sheet.dart';

/// Visits of the day on a map, colored by status; waiting visits stand out.
class DispatchWidgetMap extends StatelessWidget {
  const DispatchWidgetMap({super.key, required this.visits});
  final List<VisitDetailModel> visits;

  @override
  Widget build(BuildContext context) {
    final located = visits
        .where((v) => v.site?.latitude != null && v.site?.longitude != null)
        .toList();

    if (located.isEmpty) {
      return SingleChildScrollView(
        child: GWidgetEmpty(
          icon: Icons.location_off_rounded,
          title: 'No visits on the map'.tr,
          subtitle: 'Visits appear here when their site was picked on a map.'.tr,
        ),
      );
    }

    final points =
        located.map((v) => LatLng(v.site!.latitude!, v.site!.longitude!)).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCameraFit: points.length == 1
                    ? null
                    : CameraFit.coordinates(
                        coordinates: points,
                        padding: const EdgeInsets.all(48)),
                initialCenter: points.first,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.visit_proof',
                ),
                MarkerLayer(
                  markers: [
                    for (final visit in located)
                      Marker(
                        point: LatLng(
                            visit.site!.latitude!, visit.site!.longitude!),
                        width: 44,
                        height: 44,
                        child: _Pin(
                          visit: visit,
                          onTap: () => DispatchWidgetActionSheet.show(context,
                              DispatchWidgetVisitSheet(visitID: visit.id)),
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
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: AppTheme.shadowColor, blurRadius: 8)
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_off_rounded,
                        size: 14, color: AppTheme.pending),
                    const SizedBox(width: 4),
                    Text('Waiting'.tr,
                        style: AppTheme.font(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.textCaption,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 10),
                    Icon(Icons.engineering_rounded,
                        size: 14, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text('Assigned'.tr,
                        style: AppTheme.font(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.textCaption,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.visit, required this.onTap});
  final VisitDetailModel visit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final waiting = visit.technicianModel == null;
    final color =
        waiting ? AppTheme.pending : VisitDetailHelpers.statusColor(visit.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.onPrimary, width: 3),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: .4), blurRadius: 10)
          ],
        ),
        child: Icon(
            waiting ? Icons.person_off_rounded : Icons.engineering_rounded,
            size: 18,
            color: AppTheme.onPrimary),
      ),
    );
  }
}
