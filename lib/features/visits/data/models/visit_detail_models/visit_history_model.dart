import 'package:equatable/equatable.dart';

import '../../../../../core/utils/general_models/g_model_geo_point.dart';

class VisitHistoryModel extends Equatable {
  final String? id;
  final String? visitId;
  final DateTime? recordedAt;
  final VisitHistoryActorModel? actor;
  final String? description;
  final String? reason;

  /// Where the technician was when they made the change (admin changes
  /// have none).
  final GModelGeoPoint? location;

  /// Meters between [location] and the visit site, when the site has
  /// coordinates.
  final double? distanceFromSite;

  const VisitHistoryModel(
      {this.id,
      this.visitId,
      this.recordedAt,
      this.actor,
      this.description,
      this.reason,
      this.location,
      this.distanceFromSite});

  factory VisitHistoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VisitHistoryModel(
        id: json['id'] as String,
        visitId: json['visitId'] as String,
        recordedAt: json['recordedAt'] == null
            ? null
            : DateTime.parse(
                json['recordedAt'] as String,
              ),
        actor: json['actor'] == null
            ? null
            : VisitHistoryActorModel.fromJson(
                Map<String, dynamic>.from(json['actor']),
              ),
        description: json['description'] as String?,
        reason: json['reason'] as String?,
        location: json['location'] == null
            ? null
            : GModelGeoPoint.fromJson(
                Map<String, dynamic>.from(json['location'])),
        distanceFromSite: (json['distanceFromSite'] as num?)?.toDouble());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'visitId': visitId,
        'recordedAt': recordedAt?.toIso8601String(),
        'actor': actor?.toJson(),
        'description': description,
        'reason': reason,
        'location': location?.toJson(),
        'distanceFromSite': distanceFromSite,
      };

  @override
  List<Object?> get props => [
        id,
        visitId,
        recordedAt,
        actor,
        description,
        reason,
        location,
        distanceFromSite
      ];
}

class VisitHistoryActorModel extends Equatable {
  final String? id;
  final String? name;
  final String? role;

  const VisitHistoryActorModel({
    this.id,
    this.name,
    this.role,
  });

  factory VisitHistoryActorModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VisitHistoryActorModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        role,
      ];
}
