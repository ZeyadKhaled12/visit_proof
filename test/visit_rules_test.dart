import 'package:flutter_test/flutter_test.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/core/utils/general_models/g_model_site.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/visit_detail/domain/rules/visit_rules.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_client_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';

/// A draft with everything needed to be planned.
VisitDetailModel completeDraft({DateTime? startDate}) => VisitDetailModel(
      id: 'visit-1',
      status: VisitStatus.draft,
      client: const VisitClientModel(id: 'client-1', name: 'Client'),
      site: GModelSite(addressDetail: 'Main street 10'),
      serviceName: 'AC maintenance',
      price: 150,
      durationInMin: 60,
      startDate: startDate ?? DateTime.now().add(const Duration(days: 1)),
    );

void main() {
  group('status workflow', () {
    test('a complete future draft can be scheduled', () {
      expect(
          VisitRules.statusChangeError(
              completeDraft(), null, VisitStatus.scheduled),
          isNull);
    });

    test('an incomplete draft lists what is missing', () {
      const visit = VisitDetailModel(status: VisitStatus.draft);
      final error =
          VisitRules.statusChangeError(visit, null, VisitStatus.scheduled);
      expect(error, contains('client'));
      expect(error, contains('start date'));
    });

    test('a draft whose start time passed cannot be scheduled', () {
      final visit = completeDraft(
          startDate: DateTime.now().subtract(const Duration(hours: 1)));
      expect(VisitRules.statusChangeError(visit, null, VisitStatus.scheduled),
          isNotNull);
    });

    test('completed visits are the end of the workflow', () {
      expect(VisitRules.nextStatuses(VisitStatus.completed), isEmpty);
    });

    test('cancelling needs a reason', () {
      expect(
          VisitRules.needsReason(VisitStatus.assigned, VisitStatus.cancel),
          isTrue);
      expect(
          VisitRules.needsReason(VisitStatus.assigned, VisitStatus.onWay),
          isFalse);
    });

    test('a visit with collected money cannot be cancelled', () {
      final visit = completeDraft().copyWith(
          status: VisitStatus.assigned, technicianModel: TechnicianModel());
      const invoice = InvoiceDetailModel(
          paidAmount: 50, paymentStatus: PaymentStatus.partiallyPaid);
      expect(VisitRules.statusChangeError(visit, invoice, VisitStatus.cancel),
          isNotNull);
    });
  });

  group('technician assignment', () {
    test('a complete draft can be assigned directly', () {
      expect(VisitRules.assignError(completeDraft()), isNull);
    });

    test('an incomplete draft cannot be assigned', () {
      expect(VisitRules.assignError(const VisitDetailModel()), isNotNull);
    });

    test('nobody can be assigned once work has started', () {
      final visit = completeDraft().copyWith(status: VisitStatus.inProgress);
      expect(VisitRules.canAssignTechnician(visit), isFalse);
    });
  });

  group('deletion and invoice locks', () {
    test('only untouched drafts can be deleted', () {
      expect(VisitRules.canDelete(completeDraft(), null), isTrue);
      expect(
          VisitRules.canDelete(
              completeDraft(),
              InvoiceDetailModel(
                  issueDate: DateTime(2026),
                  paymentStatus: PaymentStatus.unpaid)),
          isFalse);
    });

    test('the service cannot change after the invoice is issued', () {
      final issued = InvoiceDetailModel(issueDate: DateTime(2026));
      expect(VisitRules.canChangeService(completeDraft(), issued), isFalse);
      expect(VisitRules.canChangeService(completeDraft(), null), isTrue);
    });
  });
}
