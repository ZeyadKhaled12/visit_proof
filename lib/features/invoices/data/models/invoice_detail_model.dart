import 'package:equatable/equatable.dart';
import '../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../core/utils/general_models/g_model_site.dart';
import '../../../visits/data/models/visit_detail_models/visit_client_model.dart';

class InvoiceDetailModel extends Equatable {
  final String? id;
  final String? invoiceNumber;

  // Related visit
  final String? visitId;
  final String? visitNumber;

  // Customer and location
  final VisitClientModel? client;
  final GModelSite? site;

  // Invoice status
  final PaymentStatus? paymentStatus;

  // Dates
  final DateTime? createdAt;
  final DateTime? issueDate;
  final DateTime? dueDate;

  // Financial details
  final num? subtotal;
  final num? discountAmount;
  final num? taxAmount;
  final num? totalAmount;
  final num? paidAmount;
  final num? remainingAmount;

  final String? currency;
  final String? notes;

  const InvoiceDetailModel({
    this.id,
    this.invoiceNumber,
    this.visitId,
    this.visitNumber,
    this.client,
    this.site,
    this.paymentStatus,
    this.createdAt,
    this.issueDate,
    this.dueDate,
    this.subtotal,
    this.discountAmount,
    this.taxAmount,
    this.totalAmount,
    this.paidAmount,
    this.remainingAmount,
    this.currency,
    this.notes,
  });

  factory InvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailModel(
      id: json['id']?.toString(),
      invoiceNumber: json['invoiceNumber'] as String?,
      visitId: json['visitId']?.toString(),
      visitNumber: json['visitNumber'] as String?,
      client: json['client'] == null
          ? null
          : VisitClientModel.fromJson(
              Map<String, dynamic>.from(json['client'] as Map),
            ),
      site: json['site'] == null
          ? null
          : GModelSite.fromJson(
              Map<String, dynamic>.from(json['site'] as Map),
            ),
      paymentStatus: json['paymentStatus'] == null
          ? null
          : PaymentStatusSwitch(
              paymentStatusID: json['paymentStatus'] as int,
            ).switchEnum(),
      createdAt: _parseDate(json['createdAt']),
      issueDate: _parseDate(json['issueDate']),
      dueDate: _parseDate(json['dueDate']),
      subtotal: _parseAmount(json['subtotal']),
      discountAmount: _parseAmount(json['discountAmount']),
      taxAmount: _parseAmount(json['taxAmount']),
      totalAmount: _parseAmount(json['totalAmount']),
      paidAmount: _parseAmount(json['paidAmount']),
      remainingAmount: _parseAmount(json['remainingAmount']),
      currency: json['currency'] as String?,
      notes: json['notes'] as String?,
    );
  }

  InvoiceDetailModel copyWith({
    String? id,
    String? invoiceNumber,
    String? visitId,
    String? visitNumber,
    VisitClientModel? client,
    GModelSite? site,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    DateTime? issueDate,
    DateTime? dueDate,
    num? subtotal,
    num? discountAmount,
    num? taxAmount,
    num? totalAmount,
    num? paidAmount,
    num? remainingAmount,
    String? currency,
    String? notes,
  }) {
    return InvoiceDetailModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      visitId: visitId ?? this.visitId,
      visitNumber: visitNumber ?? this.visitNumber,
      client: client ?? this.client,
      site: site ?? this.site,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'visitId': visitId,
        'visitNumber': visitNumber,
        'client': client?.toJson(),
        'site': site?.toJson(),
        'paymentStatus': paymentStatus == null
            ? null
            : PaymentStatusSwitch(
                paymentStatusEnum: paymentStatus,
              ).switchID(),
        'createdAt': createdAt?.toIso8601String(),
        'issueDate': issueDate?.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'subtotal': subtotal,
        'discountAmount': discountAmount,
        'taxAmount': taxAmount,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'remainingAmount': remainingAmount,
        'currency': currency,
        'notes': notes,
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static num? _parseAmount(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        visitId,
        visitNumber,
        client,
        site,
        paymentStatus,
        createdAt,
        issueDate,
        dueDate,
        subtotal,
        discountAmount,
        taxAmount,
        totalAmount,
        paidAmount,
        remainingAmount,
        currency,
        notes,
      ];
}
