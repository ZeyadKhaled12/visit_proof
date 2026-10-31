import 'package:equatable/equatable.dart';

import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../invoices/data/models/invoice_payment_history_model.dart';
import '../../../technicians/data/models/technician_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';

/// Everything the dashboard measures, read in one pass so every metric is
/// computed from the same moment in time. It only groups existing models.
class DashboardSnapshotModel extends Equatable {
  final List<VisitDetailModel>? visits;
  final List<InvoiceDetailModel>? invoices;
  final List<InvoicePaymentHistoryModel>? payments;
  final List<TechnicianModel>? technicians;
  final DateTime? loadedAt;

  const DashboardSnapshotModel({
    this.visits,
    this.invoices,
    this.payments,
    this.technicians,
    this.loadedAt,
  });

  DashboardSnapshotModel copyWith({
    List<VisitDetailModel>? visits,
    List<InvoiceDetailModel>? invoices,
    List<InvoicePaymentHistoryModel>? payments,
    List<TechnicianModel>? technicians,
    DateTime? loadedAt,
  }) {
    return DashboardSnapshotModel(
      visits: visits ?? this.visits,
      invoices: invoices ?? this.invoices,
      payments: payments ?? this.payments,
      technicians: technicians ?? this.technicians,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }

  @override
  List<Object?> get props => [visits, invoices, payments, technicians, loadedAt];
}
