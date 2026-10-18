import 'package:equatable/equatable.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';

import '../../../../core/utils/enums/technician_status_enum.dart';
import '../../../../core/utils/general_models/g_model_catg.dart';
import '../../../clients/data/models/client_detail_model/client_visit_model.dart';

class TechnicianDetailModel extends Equatable {
  final String? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? password;
  final int? openJobs;
  final int? completedJobs;
  final num? completedPaid;
  final TechnicianStatus? status;
  final List<GModelCatg>? categories;
  final List<ClientVisitModel>? visits;

  const TechnicianDetailModel(
      {this.id,
      this.name,
      this.phone,
      this.email,
      this.password,
      this.openJobs,
      this.completedJobs,
      this.completedPaid,
      this.status,
      this.categories,
      this.visits});

  factory TechnicianDetailModel.fromJson(Map<String, dynamic> json) {
    return TechnicianDetailModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      openJobs: json['openJobs'] as int?,
      completedJobs: json['completedJobs'] as int?,
      completedPaid: json['completedPaid'] as num?,
      status: json['status'] == null
          ? null
          : TechnicianStatusSwitch(technicianStatusID: json['status'])
              .switchEnum(),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => GModelCatg.fromJson(e))
          .toList(),
      visits: (json['visits'] as List<dynamic>?)
          ?.map((e) => ClientVisitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  TechnicianModel convertToTechnicianModel() => TechnicianModel(
      id: id,
      name: name,
      phone: phone,
      openJobs: openJobs,
      status: status,
      categories: categories);

  TechnicianDetailModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? password,
    int? openJobs,
    int? completedJobs,
    num? completedPaid,
    TechnicianStatus? status,
    List<GModelCatg>? categories,
    List<ClientVisitModel>? visits,
  }) {
    return TechnicianDetailModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      openJobs: openJobs ?? this.openJobs,
      completedJobs: completedJobs ?? this.completedJobs,
      completedPaid: completedPaid ?? this.completedPaid,
      status: status ?? this.status,
      categories: categories ?? this.categories,
      visits: visits ?? this.visits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'openJobs': openJobs,
      'completedJobs': completedJobs,
      'completedPaid': completedPaid,
      'status': status == null
          ? null
          : TechnicianStatusSwitch(technicianStatusEnum: status).switchID(),
      'categories': categories?.map((e) => e.toJson()).toList(),
      'visits': visits?.map((e) => e.toJson()).toList()
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        password,
        openJobs,
        completedJobs,
        completedPaid,
        status,
        categories,
        visits
      ];
}
