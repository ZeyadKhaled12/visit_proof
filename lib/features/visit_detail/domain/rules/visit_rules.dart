import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';

/// Single source of truth for what an admin may do with a visit.
///
/// The data source enforces these rules; the UI reads them to show only
/// the actions that are allowed. Invoice actions are not handled here:
/// they belong to the invoice detail screen and its own rules.
class VisitRules {
  VisitRules._();

  static const int minReasonLength = 8;
  static const int maxReasonLength = 500;
  static const int minCommentLength = 3;
  static const int maxCommentLength = 500;
  static const int maxProblemLength = 1000;
  static const int maxNotesLength = 250;

  /// The happy path of a visit, in order. Cancel sits outside it.
  static const List<VisitStatus> workflow = [
    VisitStatus.draft,
    VisitStatus.scheduled,
    VisitStatus.assigned,
    VisitStatus.onWay,
    VisitStatus.inProgress,
    VisitStatus.completed,
  ];

  static VisitStatus statusOf(VisitDetailModel visit) =>
      visit.status ?? VisitStatus.draft;

  // ==========================================================
  // STATUS WORKFLOW
  // ==========================================================

  /// Statuses reachable through "change status".
  /// Assigned is reached only by assigning a technician, and Scheduled
  /// from Assigned only by unassigning one.
  static List<VisitStatus> nextStatuses(VisitStatus status) {
    switch (status) {
      case VisitStatus.draft:
        return const [VisitStatus.scheduled, VisitStatus.cancel];
      case VisitStatus.scheduled:
        return const [VisitStatus.draft, VisitStatus.cancel];
      case VisitStatus.assigned:
        return const [VisitStatus.onWay, VisitStatus.cancel];
      case VisitStatus.onWay:
        return const [
          VisitStatus.inProgress,
          VisitStatus.assigned,
          VisitStatus.cancel
        ];
      case VisitStatus.inProgress:
        return const [VisitStatus.completed, VisitStatus.cancel];
      case VisitStatus.completed:
        return const [];
      case VisitStatus.cancel:
        return const [VisitStatus.draft];
    }
  }

  /// True when the move goes forward in the workflow (or reopens a visit).
  static bool isForward(VisitStatus from, VisitStatus to) =>
      from == VisitStatus.cancel ||
      (to != VisitStatus.cancel &&
          workflow.indexOf(to) > workflow.indexOf(from));

  static bool needsReason(VisitStatus from, VisitStatus to) =>
      to == VisitStatus.cancel ||
      from == VisitStatus.cancel ||
      (from == VisitStatus.onWay && to == VisitStatus.assigned);

  /// Why the visit cannot move to [to], or null when it can.
  static String? statusChangeError(
    VisitDetailModel visit,
    InvoiceDetailModel? invoice,
    VisitStatus to,
  ) {
    final from = statusOf(visit);

    if (!nextStatuses(from).contains(to)) {
      return 'A ${_text(from)} visit cannot move to ${_text(to)}.';
    }

    if (to == VisitStatus.scheduled) {
      final error = planningError(visit);
      if (error != null) return error;
    }

    final needsTechnician = to == VisitStatus.onWay ||
        to == VisitStatus.inProgress ||
        to == VisitStatus.completed;
    if (needsTechnician && visit.technicianModel == null) {
      return 'Assign a technician first.';
    }

    if (to == VisitStatus.cancel && hasCollectedMoney(invoice)) {
      return 'Refund all payments from the invoice before cancelling.';
    }

    return null;
  }

  /// Why a draft cannot be planned yet (scheduled or assigned), or null.
  static String? planningError(VisitDetailModel visit) {
    final missing = missingForPlanning(visit);
    if (missing.isNotEmpty) {
      return 'Complete these first: ${missing.join(', ')}.';
    }
    if (visit.startDate!.isBefore(DateTime.now())) {
      return 'The start time has already passed. Reschedule the visit first.';
    }
    return null;
  }

  static List<String> missingForPlanning(VisitDetailModel visit) => [
        if ((visit.client?.id ?? '').trim().isEmpty) 'client',
        if (visit.site == null) 'site',
        if ((visit.serviceName ?? '').trim().isEmpty) 'service',
        if (visit.price == null) 'price',
        if ((visit.durationInMin ?? 0) <= 0) 'duration',
        if (visit.startDate == null) 'start date',
      ];

  // ==========================================================
  // VISIT ACTIONS
  // ==========================================================

  /// Before the technician leaves: the plan can still change freely.
  static bool isPreDispatch(VisitDetailModel visit) {
    final status = statusOf(visit);
    return status == VisitStatus.draft ||
        status == VisitStatus.scheduled ||
        status == VisitStatus.assigned;
  }

  static bool isClosed(VisitDetailModel visit) {
    final status = statusOf(visit);
    return status == VisitStatus.completed || status == VisitStatus.cancel;
  }

  /// Like add_visit, a complete draft can go straight to Assigned.
  static bool canAssignTechnician(VisitDetailModel visit) =>
      isPreDispatch(visit);

  /// Why a technician cannot be assigned right now, or null.
  static String? assignError(VisitDetailModel visit) {
    if (!canAssignTechnician(visit)) {
      return 'Technicians can only be assigned before the visit starts.';
    }
    return statusOf(visit) == VisitStatus.draft ? planningError(visit) : null;
  }

  static bool canUnassignTechnician(VisitDetailModel visit) =>
      statusOf(visit) == VisitStatus.assigned;

  static bool canReschedule(VisitDetailModel visit) => isPreDispatch(visit);

  static bool canChangeSite(VisitDetailModel visit) =>
      isPreDispatch(visit) && visit.client != null;

  static bool canChangeProofRequirements(VisitDetailModel visit) =>
      isPreDispatch(visit);

  static bool canEditInfo(VisitDetailModel visit) => !isClosed(visit);

  /// The price comes from the service, so it can change only while
  /// the invoice is still an untouched draft.
  static bool canChangeService(
    VisitDetailModel visit,
    InvoiceDetailModel? invoice,
  ) =>
      isPreDispatch(visit) && !isInvoiceLocked(invoice);

  /// Deleting is for mistakes only: nothing financial may have happened.
  static bool canDelete(VisitDetailModel visit, InvoiceDetailModel? invoice) {
    final status = statusOf(visit);
    return (status == VisitStatus.draft || status == VisitStatus.cancel) &&
        invoice?.issueDate == null &&
        !hasCollectedMoney(invoice);
  }

  /// A technician is busy with a visit in these statuses.
  static bool occupiesTechnician(VisitStatus? status) =>
      status == VisitStatus.assigned ||
      status == VisitStatus.onWay ||
      status == VisitStatus.inProgress;

  // ==========================================================
  // INVOICE STATE (read only)
  // ==========================================================

  static bool hasCollectedMoney(InvoiceDetailModel? invoice) =>
      (invoice?.paidAmount ?? 0) > 0;

  /// Issued or paid invoices keep their amounts and site snapshot.
  static bool isInvoiceLocked(InvoiceDetailModel? invoice) =>
      invoice != null &&
      (invoice.issueDate != null || hasCollectedMoney(invoice));

  static String _text(VisitStatus status) =>
      VisitStatusSwitch(visitStatusEnum: status).getText();
}
