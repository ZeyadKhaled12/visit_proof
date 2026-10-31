import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../configs/app_toasts.dart';
import '../../../../core/local/local_pref.dart';
import '../../../../core/network/error/error_message_model.dart';
import '../../../../core/network/error/exception.dart';
import '../../../../core/network/error/handle_logic_errors.dart';
import '../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_functions.dart/g_fun_token.dart';
import '../../../../core/utils/general_models/g_model_site.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../invoices/data/models/invoice_payment_history_model.dart';
import '../../../technicians/data/models/technician_detail_model.dart';
import '../../../technicians/data/models/technician_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_history_model.dart';
import '../../domain/rules/visit_rules.dart';
import '../../domain/usecases/add_visit_comment_uc.dart';
import '../../domain/usecases/assign_technician_uc.dart';
import '../../domain/usecases/change_visit_service_uc.dart';
import '../../domain/usecases/change_visit_site_uc.dart';
import '../../domain/usecases/change_visit_status_uc.dart';
import '../../domain/usecases/delete_visit_uc.dart';
import '../../domain/usecases/get_visit_detail_uc.dart';
import '../../domain/usecases/reschedule_visit_uc.dart';
import '../../domain/usecases/unassign_technician_uc.dart';
import '../../domain/usecases/update_visit_info_uc.dart';

/// The result of one visit edit: what to store and what to log.
/// [updatedInvoice] is null when the invoice stays as it is.
typedef _VisitEdit = ({
  VisitDetailModel visit,
  InvoiceDetailModel? updatedInvoice,
  String log,
  String? reason,
});

typedef _VisitEditor = _VisitEdit Function(
  VisitDetailModel visit,
  InvoiceDetailModel? invoice,
  List<VisitDetailModel> allVisits,
);

abstract class BaseVisitDetailRemoteDataSource {
  Future<VisitDetailModel> getVisitDetail(
      GetVisitDetailParameters parameters);
  Future<VisitDetailModel> changeVisitStatus(
      ChangeVisitStatusParameters parameters);
  Future<VisitDetailModel> assignTechnician(
      AssignTechnicianParameters parameters);
  Future<VisitDetailModel> unassignTechnician(
      UnassignTechnicianParameters parameters);
  Future<VisitDetailModel> rescheduleVisit(
      RescheduleVisitParameters parameters);
  Future<VisitDetailModel> updateVisitInfo(
      UpdateVisitInfoParameters parameters);
  Future<VisitDetailModel> changeVisitService(
      ChangeVisitServiceParameters parameters);
  Future<VisitDetailModel> changeVisitSite(
      ChangeVisitSiteParameters parameters);
  Future<VisitDetailModel> addVisitComment(
      AddVisitCommentParameters parameters);
  Future<void> deleteVisit(DeleteVisitParameters parameters);
}

class VisitDetailRemoteDataSource
    extends BaseVisitDetailRemoteDataSource {
  static const String _visitsKey = 'visits';
  static const String _invoicesKey = 'invoices';
  static const String _paymentsKey = 'invoice_payments';
  static const String _techniciansKey = 'technicians';

  static const Duration _latency = Duration(milliseconds: 450);

  static const VisitHistoryActorModel _admin = VisitHistoryActorModel(
    id: 'local-admin',
    name: 'Local Admin',
    role: 'admin',
  );

  // Serialises writes inside this isolate so two edits never
  // read the same snapshot and overwrite each other.
  static Future<void> _writeQueue = Future<void>.value();

  SharedPreferences get _preferences => LocalPref.sharedPreferences;

  // ==========================================================
  // READ
  // ==========================================================

  @override
  Future<VisitDetailModel> getVisitDetail(
      GetVisitDetailParameters parameters) async {
    return await HandleLogicErrors<VisitDetailModel>(fun: () async {
      await Future.delayed(_latency);
      return _findVisit(_readVisits(), parameters.visitID);
    }).checkLogicErrors();
  }

  // ==========================================================
  // STATUS
  // ==========================================================

  @override
  Future<VisitDetailModel> changeVisitStatus(
      ChangeVisitStatusParameters parameters) {
    final to = parameters.status;

    return _updateVisit(
      parameters.visitID,
      successMessage: 'Visit moved to ${_statusText(to)}',
      edit: (visit, invoice, allVisits) {
        final from = VisitRules.statusOf(visit);

        final error = VisitRules.statusChangeError(visit, invoice, to);
        if (error != null) _fail(error);

        _checkReason(parameters.reason,
            required: VisitRules.needsReason(from, to));

        // Reopening starts the plan again, so the old technician is released.
        final reopened = from == VisitStatus.cancel;
        final updated = reopened
            ? _withoutTechnician(visit).copyWith(status: to)
            : visit.copyWith(status: to);

        return (
          visit: updated,
          updatedInvoice: _invoiceForStatus(invoice, to),
          log: 'Status changed from ${_statusText(from)} to ${_statusText(to)}',
          reason: parameters.reason,
        );
      },
    );
  }

  /// A cancelled visit cancels its invoice; reopening makes it collectible.
  InvoiceDetailModel? _invoiceForStatus(
    InvoiceDetailModel? invoice,
    VisitStatus to,
  ) {
    if (invoice == null) return null;

    if (to == VisitStatus.cancel) {
      return invoice.copyWith(paymentStatus: PaymentStatus.cancelled);
    }

    if (invoice.paymentStatus == PaymentStatus.cancelled) {
      return invoice.copyWith(paymentStatus: PaymentStatus.unpaid);
    }

    return null;
  }

  // ==========================================================
  // TECHNICIAN
  // ==========================================================

  @override
  Future<VisitDetailModel> assignTechnician(
      AssignTechnicianParameters parameters) {
    return _updateVisit(
      parameters.visitID,
      successMessage: 'Technician assigned successfully',
      edit: (visit, invoice, allVisits) {
        // Dispatch can set the time in the same step as the technician.
        final newStart = parameters.startDate;
        final planned =
            newStart == null ? visit : visit.copyWith(startDate: newStart);

        final error = VisitRules.assignError(planned);
        if (error != null) _fail(error);

        final startDate = planned.startDate;
        if (startDate == null) {
          _fail('Set a start date before assigning a technician.');
        }

        if (newStart != null && newStart.isBefore(DateTime.now())) {
          _fail('The start time must be in the future.');
        }

        _checkReason(parameters.reason, required: false);

        final technician = _findTechnician(parameters.technician.id);
        final previous = visit.technicianModel;

        if (previous?.id == technician.id) {
          _fail('${technician.name} is already assigned to this visit.');
        }

        _checkTechnicianIsFree(
          allVisits,
          visit: planned,
          technician: technician,
          start: startDate,
          durationInMin: planned.durationInMin ?? 0,
        );

        final assigned = previous == null
            ? 'Technician ${technician.name} assigned'
            : 'Technician changed from ${previous.name} to ${technician.name}';

        return (
          visit: planned.copyWith(
            status: VisitStatus.assigned,
            technicianModel: technician,
          ),
          updatedInvoice: null,
          log: newStart == null || newStart == visit.startDate
              ? assigned
              : '$assigned for ${_dateTime(startDate)}',
          reason: parameters.reason,
        );
      },
    );
  }

  @override
  Future<VisitDetailModel> unassignTechnician(
      UnassignTechnicianParameters parameters) {
    return _updateVisit(
      parameters.visitID,
      successMessage: 'Technician unassigned',
      edit: (visit, invoice, allVisits) {
        if (!VisitRules.canUnassignTechnician(visit)) {
          _fail('Only an assigned visit can release its technician. '
              'Move the visit back to Assigned first.');
        }

        _checkReason(parameters.reason, required: false);

        return (
          visit: _withoutTechnician(visit)
              .copyWith(status: VisitStatus.scheduled),
          updatedInvoice: null,
          log: 'Technician ${visit.technicianModel?.name ?? ''} unassigned',
          reason: parameters.reason,
        );
      },
    );
  }

  // ==========================================================
  // SCHEDULE, INFO, SERVICE, SITE
  // ==========================================================

  @override
  Future<VisitDetailModel> rescheduleVisit(
      RescheduleVisitParameters parameters) {
    final newStart = parameters.startDate;

    return _updateVisit(
      parameters.visitID,
      successMessage: 'Visit rescheduled',
      edit: (visit, invoice, allVisits) {
        if (!VisitRules.canReschedule(visit)) {
          _fail('Only draft, scheduled or assigned visits can be rescheduled.');
        }

        if (newStart.isBefore(DateTime.now())) {
          _fail('The new start time must be in the future.');
        }

        if (visit.startDate == newStart) {
          _fail('Pick a time different from the current one.');
        }

        _checkReason(parameters.reason, required: false);

        final technician = visit.technicianModel;
        if (technician != null) {
          _checkTechnicianIsFree(
            allVisits,
            visit: visit,
            technician: technician,
            start: newStart,
            durationInMin: visit.durationInMin ?? 0,
          );
        }

        final previous = visit.startDate;

        return (
          visit: visit.copyWith(startDate: newStart),
          updatedInvoice: null,
          log: previous == null
              ? 'Visit scheduled for ${_dateTime(newStart)}'
              : 'Visit rescheduled from ${_dateTime(previous)} '
                  'to ${_dateTime(newStart)}',
          reason: parameters.reason,
        );
      },
    );
  }

  @override
  Future<VisitDetailModel> updateVisitInfo(
      UpdateVisitInfoParameters parameters) {
    final problem = parameters.problemDescription.trim();
    final notes = parameters.notes.trim();

    return _updateVisit(
      parameters.visitID,
      successMessage: 'Visit details updated',
      edit: (visit, invoice, allVisits) {
        if (!VisitRules.canEditInfo(visit)) {
          _fail('Completed or cancelled visits cannot be edited.');
        }

        if (problem.length > VisitRules.maxProblemLength) {
          _fail('Problem description cannot exceed '
              '${VisitRules.maxProblemLength} characters.');
        }

        if (notes.length > VisitRules.maxNotesLength) {
          _fail('Notes cannot exceed ${VisitRules.maxNotesLength} characters.');
        }

        final proofChanged = parameters.requireBeforeWorkPhotos !=
                (visit.requireBeforeWorkPhotos ?? false) ||
            parameters.requireAfterWorkPhotos !=
                (visit.requireAfterWorkPhotos ?? false);

        if (proofChanged && !VisitRules.canChangeProofRequirements(visit)) {
          _fail('Photo requirements are locked once the technician '
              'is on the way.');
        }

        final nothingChanged = !proofChanged &&
            parameters.priority == visit.priority &&
            problem == (visit.problemDescription ?? '') &&
            notes == (visit.notes ?? '');

        if (nothingChanged) _fail('There are no changes to save.');

        return (
          visit: visit.copyWith(
            priority: parameters.priority,
            problemDescription: problem,
            notes: notes,
            requireBeforeWorkPhotos: parameters.requireBeforeWorkPhotos,
            requireAfterWorkPhotos: parameters.requireAfterWorkPhotos,
          ),
          updatedInvoice: null,
          log: 'Visit details updated',
          reason: null,
        );
      },
    );
  }

  @override
  Future<VisitDetailModel> changeVisitService(
      ChangeVisitServiceParameters parameters) {
    final service = parameters.service;

    return _updateVisit(
      parameters.visitID,
      successMessage: 'Service changed and invoice repriced',
      edit: (visit, invoice, allVisits) {
        if (!VisitRules.canChangeService(visit, invoice)) {
          _fail('The service can only change before dispatch and before '
              'the invoice is issued or paid.');
        }

        if ((service.serviceName ?? '').trim().isEmpty) {
          _fail('Please select a valid service.');
        }

        final duration = service.duration ?? 0;
        if (duration <= 0) {
          _fail('The selected service has no valid duration.');
        }

        final priceInCents = _cents(service.defaultPrice);

        final technician = visit.technicianModel;
        final startDate = visit.startDate;
        if (technician != null && startDate != null) {
          _checkTechnicianIsFree(
            allVisits,
            visit: visit,
            technician: technician,
            start: startDate,
            durationInMin: duration,
          );
        }

        return (
          visit: visit.copyWith(
            serviceName: service.serviceName,
            category: service.category,
            price: priceInCents / 100,
            durationInMin: duration,
            checkList: service.checkList ?? const [],
          ),
          updatedInvoice:
              invoice == null ? null : _repriceInvoice(invoice, priceInCents),
          log: 'Service changed from ${visit.serviceName ?? 'none'} '
              'to ${service.serviceName}',
          reason: null,
        );
      },
    );
  }

  /// Keeps subtotal - discount + tax = total after the price changes.
  InvoiceDetailModel _repriceInvoice(
    InvoiceDetailModel invoice,
    int subtotal,
  ) {
    final discount = _cents(invoice.discountAmount ?? 0);
    final tax = _cents(invoice.taxAmount ?? 0);

    if (discount > subtotal) {
      _fail('The invoice discount is higher than the new price. '
          'Lower the discount first.');
    }

    final total = subtotal - discount + tax;

    return invoice.copyWith(
      subtotal: subtotal / 100,
      totalAmount: total / 100,
      remainingAmount: total / 100,
    );
  }

  @override
  Future<VisitDetailModel> changeVisitSite(
      ChangeVisitSiteParameters parameters) {
    final site = parameters.site;

    return _updateVisit(
      parameters.visitID,
      successMessage: 'Visit site updated',
      edit: (visit, invoice, allVisits) {
        if (!VisitRules.canChangeSite(visit)) {
          _fail('The site can only change before the technician leaves.');
        }

        if (site.city == null) _fail('Please select a city for the site.');

        final hasAddress = (site.addressDetail ?? '').trim().isNotEmpty;
        final hasCoordinates = site.latitude != null && site.longitude != null;
        if (!hasAddress && !hasCoordinates) {
          _fail('Add an address or pick the site on the map.');
        }

        // The invoice keeps a snapshot of the site until it is issued.
        final syncInvoice =
            invoice != null && !VisitRules.isInvoiceLocked(invoice);

        return (
          visit: visit.copyWith(site: site),
          updatedInvoice: syncInvoice ? invoice.copyWith(site: site) : null,
          log: 'Site changed to ${_siteText(site)}',
          reason: null,
        );
      },
    );
  }

  // ==========================================================
  // COMMENT & DELETE
  // ==========================================================

  @override
  Future<VisitDetailModel> addVisitComment(
      AddVisitCommentParameters parameters) {
    final comment = parameters.comment.trim();

    return _updateVisit(
      parameters.visitID,
      successMessage: 'Note added',
      edit: (visit, invoice, allVisits) {
        if (comment.length < VisitRules.minCommentLength ||
            comment.length > VisitRules.maxCommentLength) {
          _fail('A note must be ${VisitRules.minCommentLength}–'
              '${VisitRules.maxCommentLength} characters.');
        }

        return (
          visit: visit,
          updatedInvoice: null,
          log: 'Admin added a note',
          reason: comment,
        );
      },
    );
  }

  @override
  Future<void> deleteVisit(DeleteVisitParameters parameters) async {
    return await HandleLogicErrors<void>(fun: () async {
      await Future.delayed(_latency);

      await _exclusive(() async {
        final visits = _readVisits();
        final invoices = _readInvoices();

        final visit = _findVisit(visits, parameters.visitID);
        final invoice = _findInvoice(invoices, visit);

        // The ledger keeps refunded payments too, so it is checked as well.
        if (!VisitRules.canDelete(visit, invoice) ||
            _hasPaymentHistory(invoice?.id)) {
          _fail('Only draft or cancelled visits with no issued invoice '
              'and no payment history can be deleted.');
        }

        visits.removeWhere((e) => e.id == visit.id);
        if (invoice != null) invoices.removeWhere((e) => e.id == invoice.id);

        await _save(visits: visits, invoices: invoices);
      });

      await AppToasts.showMessage('Visit and its invoice were deleted');
    }).checkLogicErrors();
  }

  // ==========================================================
  // SHARED UPDATE FLOW
  // ==========================================================

  /// Reads a fresh snapshot, applies [edit], appends history,
  /// keeps visit.paymentStatus in sync with the invoice and saves both.
  /// The caller reloads the invoice afterwards, since it may have changed.
  Future<VisitDetailModel> _updateVisit(
    String visitID, {
    required String successMessage,
    required _VisitEditor edit,
  }) async {
    return await HandleLogicErrors<VisitDetailModel>(fun: () async {
      await Future.delayed(_latency);

      final updated = await _exclusive(() async {
        final visits = _readVisits();
        final invoices = _readInvoices();

        final current = _findVisit(visits, visitID);
        final change = edit(current, _findInvoice(invoices, current), visits);

        final invoice = change.updatedInvoice;
        final synced = invoice == null
            ? change.visit
            : change.visit.copyWith(paymentStatus: invoice.paymentStatus);
        final visit = _withHistory(synced, change.log, change.reason);

        visits[visits.indexWhere((e) => e.id == visit.id)] = visit;
        if (invoice != null) {
          invoices[invoices.indexWhere((e) => e.id == invoice.id)] = invoice;
        }

        await _save(visits: visits, invoices: invoices);

        return visit;
      });

      await AppToasts.showMessage(successMessage);
      return updated;
    }).checkLogicErrors();
  }

  VisitDetailModel _withHistory(
    VisitDetailModel visit,
    String description,
    String? reason,
  ) {
    final note = reason?.trim() ?? '';

    return visit.copyWith(history: [
      ...?visit.history,
      VisitHistoryModel(
        id: GFunToken.generateRandomId(),
        visitId: visit.id,
        recordedAt: DateTime.now(),
        actor: _admin,
        description: description,
        reason: note.isEmpty ? null : note,
      ),
    ]);
  }

  /// copyWith cannot clear a field, so the visit is rebuilt without one.
  VisitDetailModel _withoutTechnician(VisitDetailModel visit) {
    return VisitDetailModel(
      id: visit.id,
      visitNumber: visit.visitNumber,
      status: visit.status,
      serviceName: visit.serviceName,
      client: visit.client,
      site: visit.site,
      category: visit.category,
      price: visit.price,
      durationInMin: visit.durationInMin,
      checkList: visit.checkList,
      problemDescription: visit.problemDescription,
      notes: visit.notes,
      priority: visit.priority,
      startDate: visit.startDate,
      technicianModel: null,
      history: visit.history,
      paymentStatus: visit.paymentStatus,
      invoiceID: visit.invoiceID,
      requireBeforeWorkPhotos: visit.requireBeforeWorkPhotos,
      requireAfterWorkPhotos: visit.requireAfterWorkPhotos,
    );
  }

  // ==========================================================
  // VALIDATION HELPERS
  // ==========================================================

  Never _fail(String message) =>
      throw ServerException(ErrorMessageModel(statusMessage: message));

  void _checkReason(String? reason, {required bool required}) {
    final length = reason?.trim().length ?? 0;

    if (required && length < VisitRules.minReasonLength) {
      _fail('Please give a reason of at least '
          '${VisitRules.minReasonLength} characters.');
    }

    if (length > VisitRules.maxReasonLength) {
      _fail('The reason cannot exceed ${VisitRules.maxReasonLength} '
          'characters.');
    }
  }

  /// A technician cannot be in two places at once.
  void _checkTechnicianIsFree(
    List<VisitDetailModel> allVisits, {
    required VisitDetailModel visit,
    required TechnicianModel technician,
    required DateTime start,
    required int durationInMin,
  }) {
    final end = start.add(Duration(minutes: durationInMin));

    for (final other in allVisits) {
      final otherStart = other.startDate;

      if (other.id == visit.id ||
          other.technicianModel?.id != technician.id ||
          !VisitRules.occupiesTechnician(other.status) ||
          otherStart == null) {
        continue;
      }

      final otherEnd =
          otherStart.add(Duration(minutes: other.durationInMin ?? 0));

      if (start.isBefore(otherEnd) && otherStart.isBefore(end)) {
        _fail('${technician.name ?? 'This technician'} is already booked on '
            '${other.visitNumber ?? 'another visit'} at '
            '${_dateTime(otherStart)}.');
      }
    }
  }

  /// Money is validated in cents to avoid floating point errors.
  int _cents(num? value) {
    if (value == null || !value.toDouble().isFinite || value < 0) {
      _fail('A valid, non-negative amount is required.');
    }

    final amount = value.toDouble() * 100;

    if ((amount - amount.round()).abs() > 0.000001) {
      _fail('Amounts must have at most 2 decimal places.');
    }

    return amount.round();
  }

  // ==========================================================
  // STORAGE HELPERS
  // ==========================================================

  Future<T> _exclusive<T>(Future<T> Function() action) async {
    final previous = _writeQueue;
    final release = Completer<void>();
    _writeQueue = release.future;

    await previous;

    try {
      return await action();
    } finally {
      release.complete();
    }
  }

  List<T> _readList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    return (_preferences.getStringList(key) ?? <String>[])
        .map((e) => fromJson(Map<String, dynamic>.from(jsonDecode(e) as Map)))
        .toList();
  }

  List<VisitDetailModel> _readVisits() =>
      _readList(_visitsKey, VisitDetailModel.fromJson);

  List<InvoiceDetailModel> _readInvoices() =>
      _readList(_invoicesKey, InvoiceDetailModel.fromJson);

  VisitDetailModel _findVisit(List<VisitDetailModel> visits, String visitID) {
    if (visitID.trim().isEmpty) _fail('Visit ID is required.');

    final matches = visits.where((e) => e.id == visitID).toList();

    if (matches.isEmpty) _fail('This visit no longer exists.');
    if (matches.length > 1) _fail('This visit is duplicated in storage.');

    return matches.single;
  }

  InvoiceDetailModel? _findInvoice(
    List<InvoiceDetailModel> invoices,
    VisitDetailModel visit,
  ) {
    final matches = invoices
        .where((e) =>
            e.visitId == visit.id ||
            (visit.invoiceID != null && e.id == visit.invoiceID))
        .toList();

    if (matches.length > 1) {
      _fail('This visit is linked to more than one invoice.');
    }

    return matches.firstOrNull;
  }

  TechnicianModel _findTechnician(String? technicianID) {
    final technician = _readList(_techniciansKey, TechnicianDetailModel.fromJson)
        .where((e) => e.id != null && e.id == technicianID)
        .firstOrNull;

    if (technician == null) _fail('This technician no longer exists.');

    return technician.convertToTechnicianModel();
  }

  bool _hasPaymentHistory(String? invoiceID) =>
      invoiceID != null &&
      _readList(_paymentsKey, InvoicePaymentHistoryModel.fromJson)
          .any((e) => e.invoiceId == invoiceID);

  /// SharedPreferences has no multi-key transactions: the invoice is
  /// written first, then the visit, with a best-effort rollback.
  Future<void> _save({
    required List<VisitDetailModel> visits,
    required List<InvoiceDetailModel> invoices,
  }) async {
    final oldInvoices = _preferences.getStringList(_invoicesKey);
    final oldVisits = _preferences.getStringList(_visitsKey);

    try {
      await _write(
          _invoicesKey, invoices.map((e) => jsonEncode(e.toJson())).toList());
      await _write(
          _visitsKey, visits.map((e) => jsonEncode(e.toJson())).toList());
    } catch (_) {
      await _restore(_invoicesKey, oldInvoices);
      await _restore(_visitsKey, oldVisits);
      rethrow;
    }
  }

  Future<void> _write(String key, List<String> value) async {
    final saved = await _preferences.setStringList(key, value);
    if (!saved) _fail('Could not save the changes locally.');
  }

  Future<void> _restore(String key, List<String>? value) async {
    try {
      if (value == null) {
        await _preferences.remove(key);
      } else {
        await _preferences.setStringList(key, value);
      }
    } catch (_) {
      // Rollback is best-effort only.
    }
  }

  // ==========================================================
  // TEXT HELPERS
  // ==========================================================

  String _statusText(VisitStatus status) =>
      VisitStatusSwitch(visitStatusEnum: status).getText();

  String _dateTime(DateTime value) =>
      DateFormat('dd MMM yyyy, hh:mm a').format(value);

  String _siteText(GModelSite site) => [site.city?.name, site.addressDetail]
      .where((e) => (e ?? '').trim().isNotEmpty)
      .join(' - ');
}
