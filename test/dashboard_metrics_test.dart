import 'package:flutter_test/flutter_test.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/features/dashboard/data/models/dashboard_snapshot_model.dart';
import 'package:visit_proof/features/dashboard/domain/rules/dashboard_metrics.dart';
import 'package:visit_proof/features/dashboard/domain/rules/dashboard_period.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_payment_history_model.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';

final now = DateTime(2026, 5, 20, 12);
final week = DashboardPeriod.of(DashboardRange.last7Days, now: now);

VisitDetailModel visit(String id, DateTime start, VisitStatus status,
        {TechnicianModel? tech}) =>
    VisitDetailModel(
        id: id, startDate: start, status: status, technicianModel: tech);

void main() {
  group('period', () {
    test('last 7 days ends today and the previous window touches it', () {
      expect(week.from, DateTime(2026, 5, 14));
      expect(week.to, DateTime(2026, 5, 21));
      expect(week.days, 7);
      expect(week.previous.to, week.from);
      expect(week.previous.days, 7);
    });

    test('a daylight-saving week still has 7 days', () {
      final period = DashboardPeriod.of(DashboardRange.last7Days,
          now: DateTime(2026, 11, 1, 9));
      expect(period.days, 7);
    });
  });

  group('visits and completion', () {
    final visits = [
      visit('1', DateTime(2026, 5, 15, 9), VisitStatus.completed),
      visit('2', DateTime(2026, 5, 16, 9), VisitStatus.assigned),
      visit('3', DateTime(2026, 5, 17, 9), VisitStatus.cancel),
      visit('4', DateTime(2026, 5, 22, 9), VisitStatus.scheduled), // future
      visit('5', DateTime(2026, 5, 1, 9), VisitStatus.completed), // earlier
    ];

    test('cancelled and out-of-period visits are not counted', () {
      expect(DashboardMetrics.visitsIn(visits, week).map((v) => v.id),
          containsAll(['1', '2']));
      expect(DashboardMetrics.visitsIn(visits, week).length, 2);
    });

    test('completion rate counts only visits that were due', () {
      final current = DashboardMetrics.visitsIn(visits, week);
      expect(DashboardMetrics.completionRate(current, now), .5);
    });

    test('no due visits gives no rate instead of a fake 0 %', () {
      expect(DashboardMetrics.completionRate(const [], now), isNull);
    });

    test('the trend has one bar per day split by completion', () {
      final buckets = DashboardMetrics.visitTrend(
          DashboardMetrics.visitsIn(visits, week), week);
      expect(buckets.length, 7);
      expect(buckets.fold<int>(0, (s, b) => s + b.completed), 1);
      expect(buckets.fold<int>(0, (s, b) => s + b.open), 1);
    });
  });

  group('money and attention', () {
    final invoices = [
      InvoiceDetailModel(
          id: 'inv1',
          visitId: '1',
          issueDate: DateTime(2026, 5, 1),
          dueDate: DateTime(2026, 5, 10),
          paymentStatus: PaymentStatus.partiallyPaid,
          totalAmount: 300,
          paidAmount: 100,
          remainingAmount: 200),
      const InvoiceDetailModel(
          id: 'inv2',
          visitId: '2',
          paymentStatus: PaymentStatus.unpaid,
          totalAmount: 150,
          remainingAmount: 150),
    ];
    final payments = [
      InvoicePaymentHistoryModel(
          invoiceId: 'inv1', paymentDate: DateTime(2026, 5, 18), paymentAmount: 150),
      InvoicePaymentHistoryModel(
          invoiceId: 'inv1', paymentDate: DateTime(2026, 5, 19), paymentAmount: -50),
      InvoicePaymentHistoryModel(
          invoiceId: 'inv1', paymentDate: DateTime(2026, 4, 1), paymentAmount: 999),
    ];

    test('collected is payments minus refunds inside the period', () {
      expect(DashboardMetrics.collected(payments, week), 100);
    });

    test('outstanding counts only issued, collectible invoices', () {
      expect(DashboardMetrics.outstanding(invoices), 200);
    });

    test('attention finds late, unassigned, uninvoiced and overdue items', () {
      final snapshot = DashboardSnapshotModel(
        visits: [
          visit('1', DateTime(2026, 5, 18, 9), VisitStatus.completed),
          visit('2', DateTime(2026, 5, 19, 9), VisitStatus.completed),
          visit('3', DateTime(2026, 5, 20, 8), VisitStatus.assigned),
          visit('4', DateTime(2026, 5, 25, 8), VisitStatus.scheduled),
        ],
        invoices: invoices,
      );
      final attention = DashboardMetrics.attention(snapshot, now);
      expect(attention.late.map((v) => v.id), ['3']);
      expect(attention.needsTechnician.map((v) => v.id), ['4']);
      expect(attention.readyToInvoice.map((v) => v.id), ['2']);
      expect(attention.overdueInvoices.map((i) => i.id), ['inv1']);
    });
  });

  test('technician stats follow the current technician of each visit', () {
    final ali = TechnicianModel(id: 'ali', name: 'Ali');
    final sara = TechnicianModel(id: 'sara', name: 'Sara');
    final snapshot = DashboardSnapshotModel(
      technicians: [ali, sara],
      visits: [
        visit('1', DateTime(2026, 5, 15, 9), VisitStatus.completed, tech: sara),
        visit('2', DateTime(2026, 5, 16, 9), VisitStatus.assigned, tech: sara),
        visit('3', DateTime(2026, 5, 16, 9), VisitStatus.completed, tech: ali),
      ],
    );
    final stats = DashboardMetrics.technicianStats(snapshot, week, now);
    final saraStat = stats.firstWhere((s) => s.technician.id == 'sara');
    expect(saraStat.visits.length, 2);
    expect(saraStat.completionRate, .5);
    expect(stats.first.completed, 1);
  });

  test('change handles a zero baseline without dividing by zero', () {
    expect(DashboardMetrics.change(5, 0), isNull);
    expect(DashboardMetrics.change(0, 0), 0);
    expect(DashboardMetrics.change(15, 10), .5);
  });
}
