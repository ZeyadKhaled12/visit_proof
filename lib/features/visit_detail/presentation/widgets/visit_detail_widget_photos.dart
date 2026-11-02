import 'dart:io';

import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/photo_kind_enum.dart';
import '../../../../core/utils/general_widgets/g_widget_photo_viewer.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_photo_model.dart';
import 'visit_detail_helpers.dart';
import 'visit_detail_widget_parts.dart';

/// Proof photos taken by the technician, grouped by when they were taken.
/// Shown when the visit has photos or asks for them.
class VisitDetailWidgetPhotos extends StatelessWidget {
  const VisitDetailWidgetPhotos({super.key, required this.visit});
  final VisitDetailModel visit;

  static bool shouldShow(VisitDetailModel visit) =>
      (visit.photos ?? const []).isNotEmpty ||
      (visit.requireBeforeWorkPhotos ?? false) ||
      (visit.requireAfterWorkPhotos ?? false);

  String _caption(VisitPhotoModel photo) => [
        PhotoKindSwitch(photoKindEnum: photo.kind).getText(),
        VisitDetailHelpers.dateTime(photo.takenAt),
        if ((photo.takenBy?.name ?? '').isNotEmpty) photo.takenBy!.name!,
      ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final photos = visit.photos ?? const <VisitPhotoModel>[];
    final groups = [
      (
        kind: PhotoKind.before,
        required: visit.requireBeforeWorkPhotos ?? false
      ),
      (kind: PhotoKind.after, required: visit.requireAfterWorkPhotos ?? false),
      (kind: PhotoKind.note, required: false),
      (kind: PhotoKind.receipt, required: false),
    ];

    return VisitDetailSection(
      title: 'Proof Photos'.tr,
      icon: Icons.photo_library_rounded,
      color: AppTheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final group in groups)
            if (group.required || photos.any((e) => e.kind == group.kind))
              _Group(
                kind: group.kind,
                required: group.required,
                photos: photos.where((e) => e.kind == group.kind).toList(),
                onOpen: (photo) {
                  final items = photos
                      .map((e) =>
                          GWidgetPhotoItem(path: e.path ?? '', caption: _caption(e)))
                      .toList();
                  GWidgetPhotoViewer.open(context, items,
                      initialIndex: photos.indexOf(photo));
                },
              ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.kind,
    required this.required,
    required this.photos,
    required this.onOpen,
  });

  final PhotoKind kind;
  final bool required;
  final List<VisitPhotoModel> photos;
  final ValueChanged<VisitPhotoModel> onOpen;

  @override
  Widget build(BuildContext context) {
    final kindSwitch = PhotoKindSwitch(photoKindEnum: kind);
    final color = kindSwitch.getColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('{0} ({1})'.trArgs([kindSwitch.getText(), photos.length]),
                    style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textBody,
                        fontWeight: FontWeight.w800)),
              ),
              if (required)
                VisitDetailPill(
                  text: photos.isEmpty ? 'Required'.tr : 'Done'.tr,
                  color: photos.isEmpty ? AppTheme.statOrange : AppTheme.statGreen,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (photos.isEmpty)
            Text('Not taken yet'.tr,
                style: AppTheme.font(
                    color: AppTheme.textLightHint, fontSize: AppTheme.textSmall))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final photo in photos)
                  GestureDetector(
                    onTap: () => onOpen(photo),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          border: Border.all(color: color.withValues(alpha: .5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.file(
                          File(photo.path ?? ''),
                          fit: BoxFit.cover,
                          cacheWidth: 216,
                          errorBuilder: (context, error, stack) => Container(
                            color: AppTheme.locationChipBg,
                            child: Icon(Icons.broken_image_outlined,
                                color: AppTheme.iconGrey),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
