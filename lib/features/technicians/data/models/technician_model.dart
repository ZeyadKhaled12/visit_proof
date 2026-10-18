import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';

import '../../../../core/utils/enums/technician_status_enum.dart';

class TechnicianModel {
  final String? id;
  final String? name;
  final String? phone;
  final int? openJobs;
  final TechnicianStatus? status;
  final List<GModelCatg>? categories;

  TechnicianModel(
      {this.id,
      this.name,
      this.phone,
      this.openJobs,
      this.status,
      this.categories});

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    return TechnicianModel(
        id: json['id'] as String?,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        openJobs: json['openJobs'] as int?,
        status: json['status'] == null
            ? null
            : TechnicianStatusSwitch(technicianStatusID: json['status'])
                .switchEnum(),
        categories: (json['categories'] as List<dynamic>?)
            ?.map((e) => GModelCatg.fromJson(e))
            .toList());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'openJobs': openJobs,
        'status': status == null
            ? null
            : TechnicianStatusSwitch(technicianStatusEnum: status).switchID(),
        'categories': categories?.map((e) => e.toJson()).toList()
      };
}
