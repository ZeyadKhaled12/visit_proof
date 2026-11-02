import 'package:visit_proof/configs/app_language.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../invoices/data/models/invoice_payment_history_model.dart';
import '../../../technicians/data/models/technician_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../data/models/dashboard_snapshot_model.dart';
import 'dashboard_period.dart';

/// One bar of a trend chart.
class DashboardBucket {
  final DateTime from;
  final DateTime to;
  final String label;
  final int completed;
  final int open;
  final num amount;

  const DashboardBucket({
    required this.from,
    required this.to,
    required this.label,
    this.completed = 0,
    this.open = 0,
    this.amount = 0,
  });

  int get total => completed + open;
}

/// One technician's results in a period.
class DashboardTechnicianStat {
  final TechnicianModel technician;
  final List<VisitDetailModel> visits;
  final int completed;
  final int due;
  final int activeNow;
  final num collected;

  const DashboardTechnicianStat({
    required this.technician,
    required this.visits,
    required this.completed,
    required this.due,
    required this.activeNow,
    required this.collected,
  });

  double? get completionRate => due == 0 ? null : completed / due;
}

/// Items that need the admin now, independent of the selected period.
class DashboardAttention {
  /// Planned visits whose start passed but work has not started.
  final List<VisitDetailModel> late;

  /// Scheduled visits still waiting for a technician.
  final List<VisitDetailModel> needsTechnician;

  /// Completed visits whose invoice has not been issued yet.
  final List<VisitDetailModel> readyToInvoice;

  /// Issued invoices with money still owed after their due date.
  final List<InvoiceDetailModel> overdueInvoices;

  const DashboardAttention({
    required this.late,
    required this.needsTechnician,
    required this.readyToInvoice,
    required this.overdueInvoices,
  });

  int get total =>
      late.length +
      needsTechnician.length +
      readyToInvoice.length +
      overdueInvoices.length;
}

/// Every dashboard number, defined in one place from stored visits,
/// invoices and payments. Cancelled visits never count as work.
class DashboardMetrics {
  DashboardMetrics._();

  // ==========================================================
  // VISITS
  // ==========================================================

  /// Visits whose start falls in [period]. Visits without a start date have
  /// no place in time, so they appear only in "needs attention" lists.
  static List<VisitDetailModel> visitsIn(
    List<VisitDetailModel> visits,
    DashboardPeriod period, {
    bool includeCancelled = false,
  }) =>
      visits
          .where((v) =>
              period.contains(v.startDate) &&
              (includeCancelled || v.status != VisitStatus.cancel))
          .toList()
        ..sort((a, b) => b.startDate!.compareTo(a.startDate!));

  static int completedCount(List<VisitDetailModel> visits) =>
      visits.where((v) => v.status == VisitStatus.completed).length;

  /// Visits that should be done by now: started before [now], not cancelled.
  static List<VisitDetailModel> due(
          List<VisitDetailModel> periodVisits, DateTime now) =>
      periodVisits.where((v) => v.startDate!.isBefore(now)).toList();

  /// Completed ÷ due. Null when nothing was due yet, so no fake 0 % shows.
  static double? completionRate(
      List<VisitDetailModel> periodVisits, DateTime now) {
    final dueVisits = due(periodVisits, now);
    if (dueVisits.isEmpty) return null;
    return completedCount(dueVisits) / dueVisits.length;
  }

  /// Count per status, cancelled included so the admin sees them.
  static Map<VisitStatus, int> statusCounts(List<VisitDetailModel> visits) {
    final counts = {for (final status in VisitStatus.values) status: 0};
    for (final visit in visits) {
      final status = visit.status ?? VisitStatus.draft;
      counts[status] = counts[status]! + 1;
    }
    return counts;
  }

  /// Visits per service category, busiest first.
  static List<MapEntry<String, int>> categoryCounts(
      List<VisitDetailModel> visits) {
    final counts = <String, int>{};
    for (final visit in visits) {
      final name = visit.category?.name?.tr ?? 'Uncategorized'.tr;
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  /// Today's visits, for the live operations strip.
  static List<VisitDetailModel> today(
          List<VisitDetailModel> visits, DateTime now) =>
      visitsIn(visits, DashboardPeriod.of(DashboardRange.today, now: now));

  // ==========================================================
  // MONEY
  // ==========================================================

  /// Net money received in [period]: payments minus refunds, by payment date.
  static num collected(
          List<InvoicePaymentHistoryModel> payments, DashboardPeriod period) =>
      payments
          .where((p) => period.contains(p.paymentDate))
          .fold<num>(0, (sum, p) => sum + (p.paymentAmount ?? 0));

  /// Invoices issued in [period], by issue date.
  static List<InvoiceDetailModel> issuedIn(
          List<InvoiceDetailModel> invoices, DashboardPeriod period) =>
      invoices
          .where((i) =>
              period.contains(i.issueDate) &&
              i.paymentStatus != PaymentStatus.cancelled)
          .toList();

  static num invoiced(
          List<InvoiceDetailModel> invoices, DashboardPeriod period) =>
      issuedIn(invoices, period)
          .fold<num>(0, (sum, i) => sum + (i.totalAmount ?? 0));

  /// Money still owed today on issued invoices.
  static num outstanding(List<InvoiceDetailModel> invoices) => invoices
      .where(_isCollectible)
      .fold<num>(0, (sum, i) => sum + (i.remainingAmount ?? 0));

  static bool _isCollectible(InvoiceDetailModel invoice) =>
      invoice.issueDate != null &&
      (invoice.paymentStatus == PaymentStatus.unpaid ||
          invoice.paymentStatus == PaymentStatus.partiallyPaid) &&
      (invoice.remainingAmount ?? 0) > 0;

  static List<InvoicePaymentHistoryModel> paymentsIn(
          List<InvoicePaymentHistoryModel> payments, DashboardPeriod period) =>
      payments.where((p) => period.contains(p.paymentDate)).toList()
        ..sort((a, b) => b.paymentDate!.compareTo(a.paymentDate!));

  // ==========================================================
  // ATTENTION
  // ==========================================================

  static DashboardAttention attention(
      DashboardSnapshotModel snapshot, DateTime now) {
    final visits = snapshot.visits ?? const [];
    final invoices = snapshot.invoices ?? const [];
    final today = DateTime(now.year, now.month, now.day);
    final invoiceOf = {for (final i in invoices) i.visitId: i};

    return DashboardAttention(
      late: visits
          .where((v) =>
              (v.status == VisitStatus.scheduled ||
                  v.status == VisitStatus.assigned) &&
              v.startDate != null &&
              v.startDate!.isBefore(now))
          .toList()
        ..sort((a, b) => a.startDate!.compareTo(b.startDate!)),
      needsTechnician: visits
          .where((v) =>
              v.status == VisitStatus.scheduled && v.technicianModel == null)
          .toList(),
      readyToInvoice: visits.where((v) {
        if (v.status != VisitStatus.completed) return false;
        final invoice = invoiceOf[v.id];
        return invoice != null &&
            invoice.issueDate == null &&
            invoice.paymentStatus != PaymentStatus.cancelled;
      }).toList(),
      overdueInvoices: invoices
          .where((i) =>
              _isCollectible(i) &&
              i.dueDate != null &&
              i.dueDate!.isBefore(today))
          .toList()
        ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!)),
    );
  }

  // ==========================================================
  // TECHNICIANS
  // ==========================================================

  /// Results per technician in [period], most completed visits first.
  /// A reassigned visit counts for the technician it has now.
  static List<DashboardTechnicianStat> technicianStats(
      DashboardSnapshotModel snapshot, DashboardPeriod period, DateTime now) {
    final periodVisits = visitsIn(snapshot.visits ?? const [], period);
    final invoices = snapshot.invoices ?? const [];
    final payments = paymentsIn(snapshot.payments ?? const [], period);
    final visitOfInvoice = {for (final i in invoices) i.id: i.visitId};
    final allVisits = snapshot.visits ?? const [];

    final stats = (snapshot.technicians ?? const []).map((technician) {
      final own = periodVisits
          .where((v) => v.technicianModel?.id == technician.id)
          .toList();
      final ownIDs = allVisits
          .where((v) => v.technicianModel?.id == technician.id)
          .map((v) => v.id)
          .toSet();

      return DashboardTechnicianStat(
        technician: technician,
        visits: own,
        completed: completedCount(own),
        due: due(own, now).length,
        activeNow: allVisits
            .where((v) =>
                v.technicianModel?.id == technician.id &&
                (v.status == VisitStatus.onWay ||
                    v.status == VisitStatus.inProgress))
            .length,
        collected: payments
            .where((p) => ownIDs.contains(visitOfInvoice[p.invoiceId]))
            .fold<num>(0, (sum, p) => sum + (p.paymentAmount ?? 0)),
      );
    }).toList();

    stats.sort((a, b) {
      final byCompleted = b.completed.compareTo(a.completed);
      return byCompleted != 0
          ? byCompleted
          : b.visits.length.compareTo(a.visits.length);
    });
    return stats;
  }

  // ==========================================================
  // TRENDS
  // ==========================================================

  /// Visits per day (or per week for windows longer than a month),
  /// split into completed and not yet completed.
  static List<DashboardBucket> visitTrend(
      List<VisitDetailModel> periodVisits, DashboardPeriod period) {
    return _buckets(period).map((b) {
      final inside = periodVisits.where((v) =>
          !v.startDate!.isBefore(b.from) && v.startDate!.isBefore(b.to));
      final completed = completedCount(inside.toList());
      return DashboardBucket(
          from: b.from,
          to: b.to,
          label: b.label,
          completed: completed,
          open: inside.length - completed);
    }).toList();
  }

  /// Net money collected per day (or week).
  static List<DashboardBucket> collectedTrend(
      List<InvoicePaymentHistoryModel> payments, DashboardPeriod period) {
    return _buckets(period).map((b) {
      final amount = payments
          .where((p) =>
              p.paymentDate != null &&
              !p.paymentDate!.isBefore(b.from) &&
              p.paymentDate!.isBefore(b.to))
          .fold<num>(0, (sum, p) => sum + (p.paymentAmount ?? 0));
      return DashboardBucket(
          from: b.from, to: b.to, label: b.label, amount: amount);
    }).toList();
  }

  static List<DashboardBucket> _buckets(DashboardPeriod period) {
    final weekly = period.days > 31;
    final step = weekly ? 7 : 1;
    final format = DateFormat(period.days <= 7 ? 'EEE' : 'dd/MM');
    final buckets = <DashboardBucket>[];

    for (var start = period.from;
        start.isBefore(period.to);
        start = DashboardPeriod.addDays(start, step)) {
      var end = DashboardPeriod.addDays(start, step);
      if (end.isAfter(period.to)) end = period.to;
      buckets.add(DashboardBucket(from: start, to: end, label: format.format(start)));
    }
    return buckets;
  }

  /// Relative change from [previous] to [current]; null when not comparable.
  static double? change(num current, num previous) {
    if (previous == 0) return current == 0 ? 0 : null;
    return (current - previous) / previous.abs();
  }
}
