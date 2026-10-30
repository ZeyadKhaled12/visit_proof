import '../../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../../core/utils/enums/visit_status_enum.dart';

class ClientVisitModel {
  final int? id;
  final String? visitNumber;
  final int? clientId;
  final DateTime? visitDate;
  final VisitStatus? status;
  final String? problem;
  final String? workPerformed;
  final String? technicianName;
  final String? serviceName;
  final double? totalAmount;
  final PaymentStatus? paymentStatus;

  const ClientVisitModel({
    this.id,
    this.visitNumber,
    this.clientId,
    this.visitDate,
    this.status,
    this.problem,
    this.workPerformed,
    this.technicianName,
    this.serviceName,
    this.totalAmount,
    this.paymentStatus,
  });

  factory ClientVisitModel.fromJson(Map<String, dynamic> json) {
    return ClientVisitModel(
        id: (json['id'] as num?)?.toInt(),
        visitNumber: json['visitNumber'] as String?,
        clientId: (json['clientId'] as num?)?.toInt(),
        visitDate: json['visitDate'] == null
            ? null
            : DateTime.parse(json['visit_date'] as String),
        status: json['status'] == null
            ? null
            : VisitStatusSwitch(visitStatusID: json['status'] as int?)
                .switchEnum(),
        problem: json['problem'] as String?,
        workPerformed: json['workPerformed'] as String?,
        technicianName: json['technicianName'] as String?,
        serviceName: json['serviceName'] as String?,
        totalAmount: (json['totalAmount'] as num?)?.toDouble(),
        paymentStatus: json['paymentStatus'] == null
            ? null
            : PaymentStatusSwitch(
                    paymentStatusID: json['paymentStatus'] as int?)
                .switchEnum());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitNumber': visitNumber,
      'clientId': clientId,
      'visitDate': visitDate?.toIso8601String(),
      'status': status == null
          ? null
          : VisitStatusSwitch(visitStatusEnum: status).switchID(),
      'problem': problem,
      'workPerformed': workPerformed,
      'technicianName': technicianName,
      'serviceName': serviceName,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus == null
          ? null
          : PaymentStatusSwitch(paymentStatusEnum: paymentStatus).switchID(),
    };
  }
}
