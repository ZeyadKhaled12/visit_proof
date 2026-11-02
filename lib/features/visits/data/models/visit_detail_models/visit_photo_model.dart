import 'package:equatable/equatable.dart';

import '../../../../../core/utils/enums/photo_kind_enum.dart';
import '../../../../../core/utils/general_models/g_model_geo_point.dart';
import 'visit_history_model.dart';

/// A proof photo taken by the technician. The image itself is a file on the
/// device; [path] points to it.
class VisitPhotoModel extends Equatable {
  final String? id;
  final String? path;
  final PhotoKind? kind;
  final DateTime? takenAt;
  final VisitHistoryActorModel? takenBy;

  /// Where the technician was when the photo was saved.
  final GModelGeoPoint? location;

  const VisitPhotoModel(
      {this.id,
      this.path,
      this.kind,
      this.takenAt,
      this.takenBy,
      this.location});

  factory VisitPhotoModel.fromJson(Map<String, dynamic> json) {
    return VisitPhotoModel(
      id: json['id'] as String?,
      path: json['path'] as String?,
      kind: json['kind'] == null
          ? null
          : PhotoKindSwitch(photoKindID: json['kind']).switchEnum(),
      takenAt: json['takenAt'] == null
          ? null
          : DateTime.parse(json['takenAt'] as String),
      takenBy: json['takenBy'] == null
          ? null
          : VisitHistoryActorModel.fromJson(
              Map<String, dynamic>.from(json['takenBy'])),
      location: json['location'] == null
          ? null
          : GModelGeoPoint.fromJson(Map<String, dynamic>.from(json['location'])),
    );
  }

  VisitPhotoModel copyWith({
    String? id,
    String? path,
    PhotoKind? kind,
    DateTime? takenAt,
    VisitHistoryActorModel? takenBy,
    GModelGeoPoint? location,
  }) {
    return VisitPhotoModel(
      id: id ?? this.id,
      path: path ?? this.path,
      kind: kind ?? this.kind,
      takenAt: takenAt ?? this.takenAt,
      takenBy: takenBy ?? this.takenBy,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'path': path,
        'kind': kind == null ? null : PhotoKindSwitch(photoKindEnum: kind).switchID(),
        'takenAt': takenAt?.toIso8601String(),
        'takenBy': takenBy?.toJson(),
        'location': location?.toJson(),
      };

  @override
  List<Object?> get props => [id, path, kind, takenAt, takenBy, location];
}
