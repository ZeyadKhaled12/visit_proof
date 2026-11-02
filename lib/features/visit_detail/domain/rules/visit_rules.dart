import 'package:visit_proof/configs/app_language.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../core/utils/enums/photo_kind_enum.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';

/// Single source of truth for what the current user may do with a visit.
///
/// The admin plans and edits visits. A signed-in technician only moves their
/// own visits forward (trip, work, done) and adds notes, always with their
/// live location and, where needed, proof photos.
///
/// The data source enforces these rules; the UI reads them to show only
/// the actions that are allowed. Invoice actions belong to the invoice
/// detail screen, except the technician's field collection, which is here.
class VisitRules {
  VisitRules._();

  static const int minReasonLength = 8;
  static const int maxReasonLength = 500;
  static const int minCommentLength = 3;
  static const int maxCommentLength = 500;
  static const int maxProblemLength = 1000;
  static const int maxNotesLength = 250;

  /// A technician must be this close to the site to start work.
  static const double maxStartDistanceMeters = 200;

  /// A location older than this is taken again before it is saved.
  static const Duration maxLocationAge = Duration(minutes: 3);

  /// Photos a technician can attach to one action.
  static const int maxPhotosPerAction = 6;

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
    if (AppSession.isTechnician) return technicianNextStatuses(status);
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

  /// A technician only moves the visit forward along the field steps.
  static List<VisitStatus> technicianNextStatuses(VisitStatus status) {
    switch (status) {
      case VisitStatus.assigned:
        return const [VisitStatus.onWay];
      case VisitStatus.onWay:
        return const [VisitStatus.inProgress];
      case VisitStatus.inProgress:
        return const [VisitStatus.completed];
      case VisitStatus.draft:
      case VisitStatus.scheduled:
      case VisitStatus.completed:
      case VisitStatus.cancel:
        return const [];
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

    if (AppSession.isTechnician && !isOwnVisit(visit)) {
      return 'This visit is not assigned to you.'.tr;
    }

    if (!nextStatuses(from).contains(to)) {
      return 'A {0} visit cannot move to {1}.'.trArgs([_text(from), _text(to)]);
    }

    if (to == VisitStatus.scheduled) {
      final error = planningError(visit);
      if (error != null) return error;
    }

    final needsTechnician = to == VisitStatus.onWay ||
        to == VisitStatus.inProgress ||
        to == VisitStatus.completed;
    if (needsTechnician && visit.technicianModel == null) {
      return 'Assign a technician first.'.tr;
    }

    if (to == VisitStatus.cancel && hasCollectedMoney(invoice)) {
      return 'Refund all payments from the invoice before cancelling.'.tr;
    }

    return null;
  }

  /// Why a draft cannot be planned yet (scheduled or assigned), or null.
  static String? planningError(VisitDetailModel visit) {
    final missing = missingForPlanning(visit);
    if (missing.isNotEmpty) {
      return 'Complete these first: {0}.'.trArgs([missing.join(', '.tr)]);
    }
    if (visit.startDate!.isBefore(DateTime.now())) {
      return 'The start time has already passed. Reschedule the visit first.'.tr;
    }
    return null;
  }

  static List<String> missingForPlanning(VisitDetailModel visit) => [
        if ((visit.client?.id ?? '').trim().isEmpty) 'client'.tr,
        if (visit.site == null) 'site'.tr,
        if ((visit.serviceName ?? '').trim().isEmpty) 'service'.tr,
        if (visit.price == null) 'price'.tr,
        if ((visit.durationInMin ?? 0) <= 0) 'duration'.tr,
        if (visit.startDate == null) 'start date'.tr,
      ];

  // ==========================================================
  // TECHNICIAN
  // ==========================================================

  /// The signed-in technician is the one assigned to [visit].
  static bool isOwnVisit(VisitDetailModel visit) =>
      AppSession.technicianId != null &&
      visit.technicianModel?.id == AppSession.technicianId;

  /// Technician actions must carry the technician's live location.
  static bool needsLocation() => AppSession.isTechnician;

  /// Moving to [to] proves the technician is on site, so the site distance
  /// is checked when the site has coordinates.
  static bool needsPresence(VisitStatus to) => to == VisitStatus.inProgress;

  /// The kind of proof photos taken when a technician moves to [to], or null
  /// when that step takes no photos.
  static PhotoKind? photoKindFor(VisitStatus to) {
    switch (to) {
      case VisitStatus.inProgress:
        return PhotoKind.before;
      case VisitStatus.completed:
        return PhotoKind.after;
      default:
        return null;
    }
  }

  /// The visit asks for photos at this step, so at least one is required.
  static bool photosRequired(VisitDetailModel visit, VisitStatus to) {
    switch (photoKindFor(to)) {
      case PhotoKind.before:
        return visit.requireBeforeWorkPhotos ?? false;
      case PhotoKind.after:
        return visit.requireAfterWorkPhotos ?? false;
      case PhotoKind.note:
      case PhotoKind.receipt:
      case null:
        return false;
    }
  }

  static bool siteHasCoordinates(VisitDetailModel visit) =>
      visit.site?.latitude != null && visit.site?.longitude != null;

  /// Only the admin plans, edits and deletes visits.
  static bool get _isAdmin => !AppSession.isTechnician;

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
      _isAdmin && isPreDispatch(visit);

  /// Why a technician cannot be assigned right now, or null.
  static String? assignError(VisitDetailModel visit) {
    if (!canAssignTechnician(visit)) {
      return 'Technicians can only be assigned before the visit starts.'.tr;
    }
    return statusOf(visit) == VisitStatus.draft ? planningError(visit) : null;
  }

  static bool canUnassignTechnician(VisitDetailModel visit) =>
      _isAdmin && statusOf(visit) == VisitStatus.assigned;

  static bool canReschedule(VisitDetailModel visit) =>
      _isAdmin && isPreDispatch(visit);

  static bool canChangeSite(VisitDetailModel visit) =>
      _isAdmin && isPreDispatch(visit) && visit.client != null;

  static bool canChangeProofRequirements(VisitDetailModel visit) =>
      _isAdmin && isPreDispatch(visit);

  static bool canEditInfo(VisitDetailModel visit) =>
      _isAdmin && !isClosed(visit);

  /// Admins always can; a technician only on their own open visit.
  static bool canAddComment(VisitDetailModel visit) =>
      _isAdmin || (isOwnVisit(visit) && !isClosed(visit));

  /// The admin sees every invoice; a technician sees the invoice of their
  /// own visit, so they know what to collect.
  static bool canSeeInvoice(VisitDetailModel visit) =>
      _isAdmin || isOwnVisit(visit);

  /// Issuing, editing, confirming and refunding stay with the admin.
  static bool canManageInvoice() => _isAdmin;

  /// What can still be collected: the balance minus money already
  /// waiting for the admin to confirm.
  static num collectibleAmount(InvoiceDetailModel? invoice) {
    final cents = (((invoice?.remainingAmount ?? 0) -
                    (invoice?.pendingAmount ?? 0)) *
                100)
            .round();
    return cents <= 0 ? 0 : cents / 100;
  }

  /// A technician collects on their own visit once the work has started,
  /// after the invoice is issued. The admin confirms it later.
  static bool canCollectPayment(
    VisitDetailModel visit,
    InvoiceDetailModel? invoice,
  ) {
    final status = statusOf(visit);
    final paymentStatus = invoice?.paymentStatus;
    return AppSession.isTechnician &&
        isOwnVisit(visit) &&
        (status == VisitStatus.inProgress || status == VisitStatus.completed) &&
        invoice?.issueDate != null &&
        (paymentStatus == PaymentStatus.unpaid ||
            paymentStatus == PaymentStatus.partiallyPaid ||
            paymentStatus == PaymentStatus.pending) &&
        collectibleAmount(invoice) > 0;
  }

  /// The price comes from the service, so it can change only while
  /// the invoice is still an untouched draft.
  static bool canChangeService(
    VisitDetailModel visit,
    InvoiceDetailModel? invoice,
  ) =>
      _isAdmin && isPreDispatch(visit) && !isInvoiceLocked(invoice);

  /// Deleting is for mistakes only: nothing financial may have happened.
  static bool canDelete(VisitDetailModel visit, InvoiceDetailModel? invoice) {
    final status = statusOf(visit);
    return _isAdmin &&
        (status == VisitStatus.draft || status == VisitStatus.cancel) &&
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
