import 'package:equatable/equatable.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/core/utils/general_models/g_model_site.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_client_model.dart';

import '../../../../../core/utils/enums/priority_enum.dart';
import '../../../../../core/utils/general_models/g_model_catg.dart';
import 'visit_history_model.dart';

class VisitDetailModel extends Equatable {
  final String? id;
  final String? visitNumber;
  final VisitStatus? status;
  final String? serviceName;
  final VisitClientModel? client;
  final GModelSite? site;
  final GModelCatg? category;
  final num? price;
  final int? durationInMin;
  final List<String>? checkList;
  final String? problemDescription;
  final String? notes;
  final Priority? priority;
  final DateTime? startDate;
  final TechnicianModel? technicianModel;
  final List<VisitHistoryModel>? history;
  final PaymentStatus? paymentStatus;
  final String? invoiceID;
  final bool? requireBeforeWorkPhotos;
  final bool? requireAfterWorkPhotos;

  const VisitDetailModel(
      {this.id,
      this.visitNumber,
      this.status,
      this.serviceName,
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
      this.history,
      this.paymentStatus,
      this.invoiceID,
      this.requireBeforeWorkPhotos,
      this.requireAfterWorkPhotos});

  factory VisitDetailModel.fromJson(Map<String, dynamic> json) {
    return VisitDetailModel(
        id: json['id'] as String?,
        visitNumber: json['visitNumber'] as String?,
        status: json['status'] == null
            ? null
            : VisitStatusSwitch(visitStatusID: json['status']).switchEnum(),
        serviceName: json['serviceName'] as String?,
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
        history: (json['history'] as List<dynamic>?)
            ?.map((e) => VisitHistoryModel.fromJson(e))
            .toList(),
        paymentStatus: json['paymentStatus'] == null
            ? null
            : PaymentStatusSwitch(paymentStatusID: json['paymentStatus'])
                .switchEnum(),
        invoiceID: json['invoiceID'] as String?,
        requireAfterWorkPhotos: json['requireAfterWorkPhotos'] as bool?,
        requireBeforeWorkPhotos: json['requireBeforeWorkPhotos'] as bool?);
  }

  VisitDetailModel copyWith({
    String? id,
    String? visitNumber,
    VisitStatus? status,
    String? serviceName,
    VisitClientModel? client,
    GModelSite? site,
    GModelCatg? category,
    num? price,
    int? durationInMin,
    List<String>? checkList,
    String? problemDescription,
    String? notes,
    Priority? priority,
    DateTime? startDate,
    TechnicianModel? technicianModel,
    List<VisitHistoryModel>? history,
    PaymentStatus? paymentStatus,
    String? invoiceID,
    bool? requireBeforeWorkPhotos,
    bool? requireAfterWorkPhotos,
  }) {
    return VisitDetailModel(
      id: id ?? this.id,
      visitNumber: visitNumber ?? this.visitNumber,
      status: status ?? this.status,
      serviceName: serviceName ?? this.serviceName,
      client: client ?? this.client,
      site: site ?? this.site,
      category: category ?? this.category,
      price: price ?? this.price,
      durationInMin: durationInMin ?? this.durationInMin,
      checkList: checkList ?? this.checkList,
      problemDescription: problemDescription ?? this.problemDescription,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      technicianModel: technicianModel ?? this.technicianModel,
      history: history ?? this.history,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      requireBeforeWorkPhotos:
          requireBeforeWorkPhotos ?? this.requireBeforeWorkPhotos,
      invoiceID: invoiceID ?? this.invoiceID,
      requireAfterWorkPhotos:
          requireAfterWorkPhotos ?? this.requireAfterWorkPhotos,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'visitNumber': visitNumber,
        'status': status == null
            ? null
            : VisitStatusSwitch(visitStatusEnum: status).switchID(),
        'serviceName': serviceName,
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
        'history': history?.map((e) => e.toJson()).toList(),
        'paymentStatus': paymentStatus == null
            ? null
            : PaymentStatusSwitch(paymentStatusEnum: paymentStatus).switchID(),
        'invoiceID': invoiceID,
        'requireAfterWorkPhotos': requireAfterWorkPhotos,
        'requireBeforeWorkPhotos': requireBeforeWorkPhotos
      };

  @override
  List<Object?> get props => [
        id,
        visitNumber,
        status,
        serviceName,
        client,
        site,
        category,
        price,
        durationInMin,
        checkList,
        problemDescription,
        notes,
        priority,
        startDate,
        technicianModel,
        history,
        paymentStatus,
        invoiceID,
        requireBeforeWorkPhotos,
        requireAfterWorkPhotos
      ];
}
