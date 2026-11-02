import 'package:visit_proof/core/utils/general_widgets/g_widget_local_image.dart';
import 'package:visit_proof/core/demo/demo_mode.dart';
import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/photo_kind_enum.dart';
import '../../../../core/utils/general_functions.dart/g_fun_location.dart';
import '../../../../core/utils/general_functions.dart/g_fun_photo.dart';
import '../../../../core/utils/general_models/g_model_geo_point.dart';
import '../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../../core/utils/general_widgets/g_widget_location_view_scr.dart';
import '../../../../core/utils/general_widgets/g_widget_photo_viewer.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/visit_rules.dart';
import 'visit_detail_helpers.dart';
import 'visit_detail_widget_parts.dart';

/// What the technician is about to send with an action.
class VisitFieldProofValue {
  final GModelGeoPoint? location;
  final double? distanceFromSite;
  final bool consent;
  final List<String> photoPaths;

  const VisitFieldProofValue({
    this.location,
    this.distanceFromSite,
    this.consent = false,
    this.photoPaths = const [],
  });

  bool get isStale =>
      location?.capturedAt == null ||
      DateTime.now().difference(location!.capturedAt!) >
          VisitRules.maxLocationAge - const Duration(seconds: 20);

  bool get isWithinSite =>
      distanceFromSite == null ||
      distanceFromSite! <= VisitRules.maxStartDistanceMeters;
}

/// The technician's live location (read-only, taken from GPS) with their
/// consent to share it, plus the camera photos for this step.
///
/// The location cannot be picked or edited: it is always the device's
/// current position, and the action cannot be sent until the technician
/// accepts it.
class VisitDetailWidgetFieldProof extends StatefulWidget {
  const VisitDetailWidgetFieldProof({
    super.key,
    required this.visit,
    required this.onChanged,
    this.photoKind,
    this.photosRequired = false,
    this.checkPresence = false,
  });

  final VisitDetailModel visit;
  final ValueChanged<VisitFieldProofValue> onChanged;

  /// Null hides the photo section.
  final PhotoKind? photoKind;
  final bool photosRequired;

  /// Warn when the technician is too far from the site.
  final bool checkPresence;

  @override
  State<VisitDetailWidgetFieldProof> createState() =>
      VisitDetailWidgetFieldProofState();
}

class VisitDetailWidgetFieldProofState
    extends State<VisitDetailWidgetFieldProof> {
  VisitFieldProofValue _value = const VisitFieldProofValue();
  bool _locating = true;
  GFunLocationException? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => refreshLocation());
  }

  void _update(VisitFieldProofValue value) {
    setState(() => _value = value);
    widget.onChanged(value);
  }

  /// Takes a new GPS reading. Consent is asked again for the new position.
  Future<void> refreshLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      // The website demo can pretend the visitor stands at the site.
      final location = DemoMode.simulating
          ? DemoMode.locationFor(widget.visit)
          : await GFunLocation.current();
      if (!mounted) return;
      final site = widget.visit.site;
      _update(VisitFieldProofValue(
        location: location,
        distanceFromSite: VisitRules.siteHasCoordinates(widget.visit)
            ? GFunLocation.distance(location, site!.latitude!, site.longitude!)
            : null,
        photoPaths: _value.photoPaths,
      ));
    } on GFunLocationException catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
      _update(VisitFieldProofValue(photoPaths: _value.photoPaths));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _addPhoto() async {
    final path = await GFunPhoto.takePhoto();
    if (path == null || !mounted) return;
    _update(VisitFieldProofValue(
      location: _value.location,
      distanceFromSite: _value.distanceFromSite,
      consent: _value.consent,
      photoPaths: [..._value.photoPaths, path],
    ));
  }

  void _removePhoto(String path) => _update(VisitFieldProofValue(
        location: _value.location,
        distanceFromSite: _value.distanceFromSite,
        consent: _value.consent,
        photoPaths: _value.photoPaths.where((e) => e != path).toList(),
      ));

  void _setConsent(bool consent) => _update(VisitFieldProofValue(
        location: _value.location,
        distanceFromSite: _value.distanceFromSite,
        consent: consent,
        photoPaths: _value.photoPaths,
      ));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (DemoMode.simulating) ...[
          VisitDetailNotice(
            text: 'Demo: your location is simulated at the site.'.tr,
            color: AppTheme.secondary,
            icon: Icons.science_outlined,
          ),
          const SizedBox(height: 10),
        ],
        _locationCard(),
        if (widget.photoKind != null) ...[
          const SizedBox(height: 16),
          _photos(widget.photoKind!),
        ],
      ],
    );
  }

  Widget _locationCard() {
    final location = _value.location;
    final distance = _value.distanceFromSite;
    final tooFar = widget.checkPresence && !_value.isWithinSite;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.searchFieldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.iconLightGrey.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.my_location_rounded,
                  color: AppTheme.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Your current location'.tr,
                    style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textBodyLarge,
                        fontWeight: FontWeight.w800)),
              ),
              if (_locating)
                GWidgetLoadingCircle(
                    color: AppTheme.primary,
                    width: 18,
                    height: 18,
                    strokeWidth: 2.5)
              else
                TextButton.icon(
                  onPressed: refreshLocation,
                  icon: Icon(Icons.refresh_rounded,
                      size: 18, color: AppTheme.primary),
                  label: Text('Refresh'.tr,
                      style: AppTheme.font(
                          color: AppTheme.primary,
                          fontSize: AppTheme.textSmall,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_locating && location == null)
            Text('Getting your location…'.tr,
                style: AppTheme.font(
                    color: AppTheme.textSecondary, fontSize: AppTheme.textSmall))
          else if (_error != null) ...[
            VisitDetailNotice(
                text: _error!.message,
                color: AppTheme.statOrange,
                icon: Icons.location_disabled_rounded),
            if (_error!.issue == GFunLocationIssue.deniedForever ||
                _error!.issue == GFunLocationIssue.serviceOff) ...[
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: VisitDetailActionChip(
                  label: 'Open settings'.tr,
                  icon: Icons.settings_rounded,
                  color: AppTheme.primary,
                  onTap: () => GFunLocation.openSettings(_error!.issue),
                ),
              ),
            ],
          ] else if (location != null) ...[
            Text(
                '{0}, {1} · ±{2} · {3}'.trArgs([
                  location.latitude!.toStringAsFixed(5),
                  location.longitude!.toStringAsFixed(5),
                  GFunLocation.distanceText(location.accuracy ?? 0),
                  VisitDetailHelpers.time(location.capturedAt),
                ]),
                style: AppTheme.font(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.textSmall,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            if (distance != null)
              VisitDetailNotice(
                text: tooFar
                    ? 'You are {0} from the site. Move within {1} to start work.'
                        .trArgs([
                        GFunLocation.distanceText(distance),
                        GFunLocation.distanceText(
                            VisitRules.maxStartDistanceMeters),
                      ])
                    : '{0} from the site'
                        .trArgs([GFunLocation.distanceText(distance)]),
                color: tooFar ? AppTheme.statOrange : AppTheme.statGreen,
                icon: tooFar
                    ? Icons.wrong_location_rounded
                    : Icons.where_to_vote_rounded,
              )
            else
              VisitDetailNotice(
                text:
                    'This site has no map location, so your current location is sent to the admin instead.'
                        .tr,
                color: AppTheme.secondary,
              ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: VisitDetailActionChip(
                label: 'View on map'.tr,
                icon: Icons.map_rounded,
                color: AppTheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GWidgetLocationViewScr(
                        latitude: location.latitude!,
                        longitude: location.longitude!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            CheckboxListTile(
              value: _value.consent,
              onChanged: (value) => _setConsent(value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppTheme.primary,
              title: Text(
                  'I confirm this is my current location and agree to share it with the admin.'
                      .tr,
                  style: AppTheme.font(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.textSmall,
                      fontWeight: FontWeight.w600,
                      height: 1.4)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _photos(PhotoKind kind) {
    final kindSwitch = PhotoKindSwitch(photoKindEnum: kind);
    final color = kindSwitch.getColor();
    final paths = _value.photoPaths;
    final canAdd = paths.length < VisitRules.maxPhotosPerAction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.photo_camera_rounded, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                  '{0} photos'.trArgs([kindSwitch.getText()]),
                  style: AppTheme.font(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.textBodyLarge,
                      fontWeight: FontWeight.w800)),
            ),
            VisitDetailPill(
              text: widget.photosRequired ? 'Required'.tr : 'Optional'.tr,
              color: widget.photosRequired ? AppTheme.statOrange : AppTheme.iconGrey,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < paths.length; i++)
              _Thumb(
                path: paths[i],
                onOpen: () => GWidgetPhotoViewer.open(
                    context,
                    paths
                        .map((e) => GWidgetPhotoItem(path: e))
                        .toList(),
                    initialIndex: i),
                onRemove: () => _removePhoto(paths[i]),
              ),
            if (canAdd)
              _AddPhoto(color: color, onTap: _addPhoto),
          ],
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb(
      {required this.path, required this.onOpen, required this.onRemove});
  final String path;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onOpen,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: GWidgetLocalImage(
                    path: path,
                    fit: BoxFit.cover,
                    cacheWidth: 228,
                    errorBuilder: (context, error, stack) => Container(
                        color: AppTheme.locationChipBg,
                        child: Icon(Icons.broken_image_outlined,
                            color: AppTheme.iconGrey))),
              ),
            ),
          ),
          PositionedDirectional(
            top: 4,
            end: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: AppTheme.statOrange, shape: BoxShape.circle),
                child: Icon(Icons.close_rounded,
                    size: 14, color: AppTheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhoto extends StatelessWidget {
  const _AddPhoto({required this.color, required this.onTap});
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: .5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_rounded, color: color, size: 24),
              const SizedBox(height: 4),
              Text('Add'.tr,
                  style: AppTheme.font(
                      color: color,
                      fontSize: AppTheme.textCaption,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
