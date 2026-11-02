import 'package:equatable/equatable.dart';

import '../../../../core/utils/enums/payment_entry_status_enum.dart';
import '../../../../core/utils/enums/payment_method_enum.dart';
import '../../../../core/utils/general_models/g_model_geo_point.dart';
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

  /// Null for entries saved before field collection existed: confirmed.
  final PaymentEntryStatus? status;

  /// Field proof of a technician's collection: where it happened and
  /// the receipt photos (file paths on this device).
  final GModelGeoPoint? location;
  final List<String>? photos;

  /// The admin's decision on a field collection.
  final VisitHistoryActorModel? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNote;

  const InvoicePaymentHistoryModel({
    this.id,
    this.invoiceId,
    this.paymentDate,
    this.paymentAmount,
    this.paymentMethod,
    this.collectedBy,
    this.referenceNumber,
    this.notes,
    this.status,
    this.location,
    this.photos,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNote,
  });

  PaymentEntryStatus get entryStatus => status ?? PaymentEntryStatus.confirmed;

  bool get isPending => entryStatus == PaymentEntryStatus.pending;

  /// Only confirmed entries count towards the invoice's paid amount.
  bool get countsAsPaid => entryStatus == PaymentEntryStatus.confirmed;

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
      status: json['status'] == null
          ? null
          : PaymentEntryStatusSwitch(
              paymentEntryStatusID: json['status'] as int,
            ).switchEnum(),
      location: json['location'] == null
          ? null
          : GModelGeoPoint.fromJson(
              Map<String, dynamic>.from(json['location'] as Map),
            ),
      photos: json['photos'] == null
          ? null
          : List<String>.from(json['photos'] as List),
      reviewedBy: json['reviewedBy'] == null
          ? null
          : VisitHistoryActorModel.fromJson(
              Map<String, dynamic>.from(json['reviewedBy'] as Map),
            ),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.tryParse(json['reviewedAt'].toString()),
      reviewNote: json['reviewNote'] as String?,
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
    PaymentEntryStatus? status,
    GModelGeoPoint? location,
    List<String>? photos,
    VisitHistoryActorModel? reviewedBy,
    DateTime? reviewedAt,
    String? reviewNote,
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
      status: status ?? this.status,
      location: location ?? this.location,
      photos: photos ?? this.photos,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewNote: reviewNote ?? this.reviewNote,
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
        'status': status == null
            ? null
            : PaymentEntryStatusSwitch(paymentEntryStatusEnum: status)
                .switchID(),
        'location': location?.toJson(),
        'photos': photos,
        'reviewedBy': reviewedBy?.toJson(),
        'reviewedAt': reviewedAt?.toIso8601String(),
        'reviewNote': reviewNote,
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
        status,
        location,
        photos,
        reviewedBy,
        reviewedAt,
        reviewNote,
      ];
}
