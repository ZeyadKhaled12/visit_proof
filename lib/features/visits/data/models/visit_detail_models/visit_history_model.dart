import 'package:equatable/equatable.dart';

class VisitHistoryModel extends Equatable {
  final String? id;
  final String? visitId;
  final DateTime? recordedAt;
  final VisitHistoryActorModel? actor;
  final String? description;
  final String? reason;

  const VisitHistoryModel(
      {this.id,
      this.visitId,
      this.recordedAt,
      this.actor,
      this.description,
      this.reason});

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
        reason: json['reason'] as String?);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'visitId': visitId,
        'recordedAt': recordedAt?.toIso8601String(),
        'actor': actor?.toJson(),
        'description': description,
        'reason': reason,
      };

  @override
  List<Object?> get props =>
      [id, visitId, recordedAt, actor, description, reason];
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
