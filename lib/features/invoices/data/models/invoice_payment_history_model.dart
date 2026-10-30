import 'package:equatable/equatable.dart';

import '../../../../core/utils/enums/payment_method_enum.dart';
import '../../../visits/data/models/visit_detail_models/visit_history_model.dart';

class InvoicePaymentHistoryModel extends Equatable {
  final String? id;
  final String? invoiceId;

  // Payment details
  final DateTime? paymentDate;
  final num? paymentAmount;
  final PaymentMethod? paymentMethod;

  // Who collected the money
  final VisitHistoryActorModel? collectedBy;

  // Additional information
  final String? referenceNumber;
  final String? notes;

  const InvoicePaymentHistoryModel({
    this.id,
    this.invoiceId,
    this.paymentDate,
    this.paymentAmount,
    this.paymentMethod,
    this.collectedBy,
    this.referenceNumber,
    this.notes,
  });

  factory InvoicePaymentHistoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return InvoicePaymentHistoryModel(
      id: json['id']?.toString(),
      invoiceId: json['invoiceId']?.toString(),
      paymentDate: json['paymentDate'] == null
          ? null
          : DateTime.tryParse(
              json['paymentDate'].toString(),
            ),
      paymentAmount: json['paymentAmount'] is num
          ? json['paymentAmount'] as num
          : num.tryParse(
              json['paymentAmount']?.toString() ?? '',
            ),
      paymentMethod: json['paymentMethod'] == null
          ? null
          : PaymentMethodSwitch(
              paymentMethodID: json['paymentMethod'] as int,
            ).switchEnum(),
      collectedBy: json['collectedBy'] == null
          ? null
          : VisitHistoryActorModel.fromJson(
              Map<String, dynamic>.from(
                json['collectedBy'] as Map,
              ),
            ),
      referenceNumber: json['referenceNumber'] as String?,
      notes: json['notes'] as String?,
    );
  }

  InvoicePaymentHistoryModel copyWith({
    String? id,
    String? invoiceId,
    DateTime? paymentDate,
    num? paymentAmount,
    PaymentMethod? paymentMethod,
    VisitHistoryActorModel? collectedBy,
    String? referenceNumber,
    String? notes,
  }) {
    return InvoicePaymentHistoryModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      collectedBy: collectedBy ?? this.collectedBy,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceId': invoiceId,
        'paymentDate': paymentDate?.toIso8601String(),
        'paymentAmount': paymentAmount,
        'paymentMethod': paymentMethod == null
            ? null
            : PaymentMethodSwitch(
                paymentMethodEnum: paymentMethod,
              ).switchID(),
        'collectedBy': collectedBy?.toJson(),
        'referenceNumber': referenceNumber,
        'notes': notes,
      };

  @override
  List<Object?> get props => [
        id,
        invoiceId,
        paymentDate,
        paymentAmount,
        paymentMethod,
        collectedBy,
        referenceNumber,
        notes,
      ];
}
