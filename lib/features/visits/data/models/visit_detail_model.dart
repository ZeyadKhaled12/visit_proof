import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/core/utils/general_models/g_model_site.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_client_model.dart';

import '../../../../core/utils/enums/priority_enum.dart';
import '../../../../core/utils/general_models/g_model_catg.dart';

class VisitDetailModel {
  final String? id;
  final VisitStatus? status;
  final VisitClientModel? client; //////////////////
  final GModelSite? site; /////////////////////////
  final GModelCatg? category; ////////////////////
  final num? price; /////////////////////////////
  final int? durationInMin; ////////////////////
  final List<String>? checkList; //////////////
  final String? problemDescription;///////////
  final String? notes;///////////////////////
  final Priority? priority;/////////////////
  final DateTime? startDate;
  final TechnicianModel? technicianModel;//////
  final bool? requireBeforeWorkPhotos;////////
  final bool? requireAfterWorkPhotos;/////////

  VisitDetailModel(
      {this.id,
      this.status,
      this.client,
      this.site,
      this.category,
      this.price,
      this.durationInMin,
      this.checkList,
      this.problemDescription,
      this.notes,
      this.priority,
      this.startDate,
      this.technicianModel,
      this.requireBeforeWorkPhotos,
      this.requireAfterWorkPhotos});

  factory VisitDetailModel.fromJson(Map<String, dynamic> json) {
    return VisitDetailModel(
        id: json['id'] as String?,
        status: json['status'] == null
            ? null
            : VisitStatusSwitch(visitStatusID: json['status']).switchEnum(),
        client: json['client'] == null
            ? null
            : VisitClientModel.fromJson(json['client']),
        site: json['site'] == null ? null : GModelSite.fromJson(json['site']),
        category: json['category'] == null
            ? null
            : GModelCatg.fromJson(json['category']),
        price: json['price'] as num?,
        durationInMin: json['duration'] as int?,
        checkList: (json['checkList'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        problemDescription: json['problem'] as String?,
        notes: json['notes'] as String?,
        priority: json['priority'] == null
            ? null
            : PrioritySwitch(priorityID: json['priority']).switchEnum(),
        startDate: json['startDate'] == null
            ? null
            : DateTime.parse(json['startDate'] as String),
        technicianModel: json['technician'] == null
            ? null
            : TechnicianModel.fromJson(json['technician']),
        requireAfterWorkPhotos: json['requireAfterWorkPhotos'] as bool?,
        requireBeforeWorkPhotos: json['requireBeforeWorkPhotos'] as bool?);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status == null
            ? null
            : VisitStatusSwitch(visitStatusEnum: status).switchID(),
        'client': client?.toJson(),
        'site': site?.toJson(),
        'category': category?.toJson(),
        'price': price,
        'duration': durationInMin,
        'checkList': checkList?.toList(),
        'problem': problemDescription,
        'notes': notes,
        'priority': priority == null
            ? null
            : PrioritySwitch(priorityEnum: priority).switchID(),
        'startDate': startDate?.toIso8601String(),
        'technician': technicianModel?.toJson(),
        'requireAfterWorkPhotos': requireAfterWorkPhotos,
        'requireBeforeWorkPhotos': requireBeforeWorkPhotos
      };
}
