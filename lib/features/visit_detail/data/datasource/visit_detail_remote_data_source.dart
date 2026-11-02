import 'package:visit_proof/configs/app_language.dart';
import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/app.dart';
import '../../../../configs/app_toasts.dart';
import '../../../../core/local/local_photos.dart';
import '../../../../core/local/local_pref.dart';
import '../../../../core/network/error/error_message_model.dart';
import '../../../../core/network/error/exception.dart';
import '../../../../core/network/error/handle_logic_errors.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../core/utils/enums/photo_kind_enum.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_functions.dart/g_fun_location.dart';
import '../../../../core/utils/general_functions.dart/g_fun_token.dart';
import '../../../../core/utils/general_models/g_model_geo_point.dart';
import '../../../../core/utils/general_models/g_model_site.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../invoices/data/models/invoice_payment_history_model.dart';
import '../../../technicians/data/models/technician_detail_model.dart';
import '../../../technicians/data/models/technician_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_history_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_photo_model.dart';
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

/// What a technician sends with an action: where they are and the photos
/// they took. Admin actions send none.
typedef _FieldProof = ({
  GModelGeoPoint? location,
  List<String> photoPaths,
  PhotoKind? photoKind,
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
      final visit = _findVisit(_readVisits(), parameters.visitID);
      if (AppSession.isTechnician && !VisitRules.isOwnVisit(visit)) {
        _fail('This visit is not assigned to you.'.tr);
      }
      return visit;
    }).checkLogicErrors();
  }

  // ==========================================================
  // STATUS
  // ==========================================================

  @override
  Future<VisitDetailModel> changeVisitStatus(
      ChangeVisitStatusParameters parameters) {
    final to = parameters.status;
    final photoKind = VisitRules.photoKindFor(to);

    return _updateVisit(
      parameters.visitID,
      successMessage: 'Visit moved to {0}'.trArgs([_statusText(to)]),
      proof: (
        location: parameters.location,
        photoPaths: parameters.photoPaths,
        photoKind: photoKind,
      ),
      edit: (visit, invoice, allVisits) {
        final from = VisitRules.statusOf(visit);

        final error = VisitRules.statusChangeError(visit, invoice, to);
        if (error != null) _fail(error);

        _checkReason(parameters.reason,
            required: VisitRules.needsReason(from, to));

        if (AppSession.isTechnician) {
          if (VisitRules.photosRequired(visit, to) &&
              parameters.photoPaths.isEmpty) {
            _fail('This visit needs at least one {0} photo.'.trArgs([
              PhotoKindSwitch(photoKindEnum: photoKind).getText().toLowerCase()
            ]));
          }
          if (VisitRules.needsPresence(to)) {
            _checkOnSite(visit, parameters.location!);
          }
        }

        // Reopening starts the plan again, so the old technician is released.
        final reopened = from == VisitStatus.cancel;
        final updated = reopened
            ? _withoutTechnician(visit).copyWith(status: to)
            : visit.copyWith(status: to);

        final updatedInvoice = _invoiceForStatus(invoice, to);
        final log = 'Status changed from {0} to {1}'
            .trArgs([_statusText(from), _statusText(to)]);
        final autoIssued =
            invoice?.issueDate == null && updatedInvoice?.issueDate != null;

        return (
          visit: updated,
          updatedInvoice: updatedInvoice,
          log: autoIssued
              ? '{0} · {1}'.trArgs([log, 'Invoice issued automatically'.tr])
              : log,
          reason: parameters.reason,
        );
      },
    );
  }

  /// A cancelled visit cancels its invoice; reopening makes it collectible.
  /// Completing the visit issues its untouched draft invoice, so the
  /// technician can collect on site without waiting for the admin.
  InvoiceDetailModel? _invoiceForStatus(
    InvoiceDetailModel? invoice,
    VisitStatus to,
  ) {
    if (invoice == null) return null;

    if (to == VisitStatus.completed &&
        invoice.issueDate == null &&
        invoice.paymentStatus == PaymentStatus.unpaid &&
        (invoice.paidAmount ?? 0) == 0 &&
        (invoice.totalAmount ?? 0) > 0) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final due = invoice.dueDate;
      return invoice.copyWith(
        issueDate: now,
        dueDate: due != null && !due.isBefore(today)
            ? due
            : today.add(Duration(days: App.invoicePaymentTermDays)),
      );
    }

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
      adminOnly: true,
      successMessage: 'Technician assigned successfully'.tr,
      edit: (visit, invoice, allVisits) {
        // Dispatch can set the time in the same step as the technician.
        final newStart = parameters.startDate;
        final planned =
            newStart == null ? visit : visit.copyWith(startDate: newStart);

        final error = VisitRules.assignError(planned);
        if (error != null) _fail(error);

        final startDate = planned.startDate;
        if (startDate == null) {
          _fail('Set a start date before assigning a technician.'.tr);
        }

        if (newStart != null && newStart.isBefore(DateTime.now())) {
          _fail('The start time must be in the future.'.tr);
        }

        _checkReason(parameters.reason, required: false);

        final technician = _findTechnician(parameters.technician.id);
        final previous = visit.technicianModel;

        if (previous?.id == technician.id) {
          _fail('{0} is already assigned to this visit.'.trArgs([technician.name]));
        }

        _checkTechnicianIsFree(
          allVisits,
          visit: planned,
          technician: technician,
          start: startDate,
          durationInMin: planned.durationInMin ?? 0,
        );

        final assigned = previous == null
            ? 'Technician {0} assigned'.trArgs([technician.name])
            : 'Technician changed from {0} to {1}'.trArgs([previous.name, technician.name]);

        return (
          visit: planned.copyWith(
            status: VisitStatus.assigned,
            technicianModel: technician,
          ),
          updatedInvoice: null,
          log: newStart == null || newStart == visit.startDate
              ? assigned
              : '{0} for {1}'.trArgs([assigned, _dateTime(startDate)]),
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
      adminOnly: true,
      successMessage: 'Technician unassigned'.tr,
      edit: (visit, invoice, allVisits) {
        if (!VisitRules.canUnassignTechnician(visit)) {
          _fail('Only an assigned visit can release its technician. Move the visit back to Assigned first.'.tr);
        }

        _checkReason(parameters.reason, required: false);

        return (
          visit: _withoutTechnician(visit)
              .copyWith(status: VisitStatus.scheduled),
          updatedInvoice: null,
          log: 'Technician {0} unassigned'.trArgs([visit.technicianModel?.name ?? '']),
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
      adminOnly: true,
      successMessage: 'Visit rescheduled'.tr,
      edit: (visit, invoice, allVisits) {
        if (!VisitRules.canReschedule(visit)) {
          _fail('Only draft, scheduled or assigned visits can be rescheduled.'.tr);
        }

        if (newStart.isBefore(DateTime.now())) {
          _fail('The new start time must be in the future.'.tr);
        }

        if (visit.startDate == newStart) {
          _fail('Pick a time different from the current one.'.tr);
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
              ? 'Visit scheduled for {0}'.trArgs([_dateTime(newStart)])
              : 'Visit rescheduled from {0} to {1}'.trArgs([_dateTime(previous), _dateTime(newStart)]),
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
      adminOnly: true,
      successMessage: 'Visit details updated'.tr,
      edit: (visit, invoice, allVisits) {
        if (!VisitRules.canEditInfo(visit)) {
          _fail('Completed or cancelled visits cannot be edited.'.tr);
        }

        if (problem.length > VisitRules.maxProblemLength) {
          _fail('Problem description cannot exceed {0} characters.'.trArgs([VisitRules.maxProblemLength]));
        }

        if (notes.length > VisitRules.maxNotesLength) {
          _fail('Notes cannot exceed {0} characters.'.trArgs([VisitRules.maxNotesLength]));
        }

        final proofChanged = parameters.requireBeforeWorkPhotos !=
                (visit.requireBeforeWorkPhotos ?? false) ||
            parameters.requireAfterWorkPhotos !=
                (visit.requireAfterWorkPhotos ?? false);

        if (proofChanged && !VisitRules.canChangeProofRequirements(visit)) {
          _fail('Photo requirements are locked once the technician is on the way.'.tr);
        }

        final nothingChanged = !proofChanged &&
            parameters.priority == visit.priority &&
            problem == (visit.problemDescription ?? '') &&
            notes == (visit.notes ?? '');

        if (nothingChanged) _fail('There are no changes to save.'.tr);

        return (
          visit: visit.copyWith(
            priority: parameters.priority,
            problemDescription: problem,
            notes: notes,
            requireBeforeWorkPhotos: parameters.requireBeforeWorkPhotos,
            requireAfterWorkPhotos: parameters.requireAfterWorkPhotos,
          ),
          updatedInvoice: null,
          log: 'Visit details updated'.tr,
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
      adminOnly: true,
      successMessage: 'Service changed and invoice repriced'.tr,
      edit: (visit, invoice, allVisits) {
        if (!VisitRules.canChangeService(visit, invoice)) {
          _fail('The service can only change before dispatch and before the invoice is issued or paid.'.tr);
        }

        if ((service.serviceName ?? '').trim().isEmpty) {
          _fail('Please select a valid service.'.tr);
        }

        final duration = service.duration ?? 0;
        if (duration <= 0) {
          _fail('The selected service has no valid duration.'.tr);
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
          log: 'Service changed from {0} to {1}'.trArgs([visit.serviceName ?? 'none'.tr, service.serviceName]),
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
      _fail('The invoice discount is higher than the new price. Lower the discount first.'.tr);
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
      adminOnly: true,
      successMessage: 'Visit site updated'.tr,
      edit: (visit, invoice, allVisits) {
        if (!VisitRules.canChangeSite(visit)) {
          _fail('The site can only change before the technician leaves.'.tr);
        }

        if (site.city == null) _fail('Please select a city for the site.'.tr);

        final hasAddress = (site.addressDetail ?? '').trim().isNotEmpty;
        final hasCoordinates = site.latitude != null && site.longitude != null;
        if (!hasAddress && !hasCoordinates) {
          _fail('Add an address or pick the site on the map.'.tr);
        }

        // The invoice keeps a snapshot of the site until it is issued.
        final syncInvoice =
            invoice != null && !VisitRules.isInvoiceLocked(invoice);

        return (
          visit: visit.copyWith(site: site),
          updatedInvoice: syncInvoice ? invoice.copyWith(site: site) : null,
          log: 'Site changed to {0}'.trArgs([_siteText(site)]),
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
      successMessage: 'Note added'.tr,
      proof: (
        location: parameters.location,
        photoPaths: parameters.photoPaths,
        photoKind: PhotoKind.note,
      ),
      edit: (visit, invoice, allVisits) {
        if (!VisitRules.canAddComment(visit)) {
          _fail('Notes can only be added to your open visits.'.tr);
        }

        if (comment.length < VisitRules.minCommentLength ||
            comment.length > VisitRules.maxCommentLength) {
          _fail('A note must be {0}–{1} characters.'.trArgs([VisitRules.minCommentLength, VisitRules.maxCommentLength]));
        }

        return (
          visit: visit,
          updatedInvoice: null,
          log: AppSession.isTechnician
              ? 'Technician added a note'.tr
              : 'Admin added a note'.tr,
          reason: comment,
        );
      },
    );
  }

  @override
  Future<void> deleteVisit(DeleteVisitParameters parameters) async {
    return await HandleLogicErrors<void>(fun: () async {
      await Future.delayed(_latency);
      _requireAdmin();

      await _exclusive(() async {
        final visits = _readVisits();
        final invoices = _readInvoices();

        final visit = _findVisit(visits, parameters.visitID);
        final invoice = _findInvoice(invoices, visit);

        // The ledger keeps refunded payments too, so it is checked as well.
        if (!VisitRules.canDelete(visit, invoice) ||
            _hasPaymentHistory(invoice?.id)) {
          _fail('Only draft or cancelled visits with no issued invoice and no payment history can be deleted.'.tr);
        }

        visits.removeWhere((e) => e.id == visit.id);
        if (invoice != null) invoices.removeWhere((e) => e.id == invoice.id);

        await _save(visits: visits, invoices: invoices);
        await LocalPhotos.removeVisit(visit.id!);
      });

      await AppToasts.showMessage('Visit and its invoice were deleted'.tr);
    }).checkLogicErrors();
  }

  // ==========================================================
  // SHARED UPDATE FLOW
  // ==========================================================

  /// Reads a fresh snapshot, applies [edit], appends history,
  /// keeps visit.paymentStatus in sync with the invoice and saves both.
  /// The caller reloads the invoice afterwards, since it may have changed.
  ///
  /// [adminOnly] actions are refused for technicians. For a technician,
  /// [proof] must carry a fresh location; it is logged with the change and
  /// its photos are stored with the visit.
  Future<VisitDetailModel> _updateVisit(
    String visitID, {
    required String successMessage,
    required _VisitEditor edit,
    bool adminOnly = false,
    _FieldProof? proof,
  }) async {
    return await HandleLogicErrors<VisitDetailModel>(fun: () async {
      await Future.delayed(_latency);
      if (adminOnly) _requireAdmin();

      final updated = await _exclusive(() async {
        final visits = _readVisits();
        final invoices = _readInvoices();

        final current = _findVisit(visits, visitID);
        final location = _checkFieldProof(current, proof);
        final change = edit(current, _findInvoice(invoices, current), visits);

        final invoice = change.updatedInvoice;
        final synced = invoice == null
            ? change.visit
            : change.visit.copyWith(paymentStatus: invoice.paymentStatus);

        final photos = await _keepPhotos(synced, proof, location);
        final withPhotos = photos.isEmpty
            ? synced
            : synced.copyWith(photos: [...?synced.photos, ...photos]);
        final visit = _withHistory(
          withPhotos,
          photos.isEmpty
              ? change.log
              : '{0} · {1} photo{2}'.trArgs(
                  [change.log, photos.length, photos.length == 1 ? '' : 's']),
          change.reason,
          location: location,
        );

        visits[visits.indexWhere((e) => e.id == visit.id)] = visit;
        if (invoice != null) {
          invoices[invoices.indexWhere((e) => e.id == invoice.id)] = invoice;
        }

        try {
          await _save(visits: visits, invoices: invoices);
        } catch (_) {
          await LocalPhotos.remove(photos.map((e) => e.path!));
          rethrow;
        }

        return visit;
      });

      await AppToasts.showMessage(successMessage);
      return updated;
    }).checkLogicErrors();
  }

  VisitDetailModel _withHistory(
    VisitDetailModel visit,
    String description,
    String? reason, {
    GModelGeoPoint? location,
  }) {
    final note = reason?.trim() ?? '';

    return visit.copyWith(history: [
      ...?visit.history,
      VisitHistoryModel(
        id: GFunToken.generateRandomId(),
        visitId: visit.id,
        recordedAt: DateTime.now(),
        actor: AppSession.actor,
        description: description,
        reason: note.isEmpty ? null : note,
        location: location,
        distanceFromSite:
            location == null ? null : _distanceFromSite(visit, location),
      ),
    ]);
  }

  /// Copies the technician's photos next to the visit. Files already copied
  /// are removed again if a later one fails.
  Future<List<VisitPhotoModel>> _keepPhotos(
    VisitDetailModel visit,
    _FieldProof? proof,
    GModelGeoPoint? location,
  ) async {
    final paths = proof?.photoPaths ?? const <String>[];
    if (paths.isEmpty) return const [];

    final kept = <VisitPhotoModel>[];
    try {
      for (final path in paths) {
        final id = GFunToken.generateRandomId();
        kept.add(VisitPhotoModel(
          id: id,
          path: await LocalPhotos.keep(
              tempPath: path, visitID: visit.id!, photoID: id),
          kind: proof!.photoKind,
          takenAt: DateTime.now(),
          takenBy: AppSession.actor,
          location: location,
        ));
      }
    } catch (_) {
      await LocalPhotos.remove(kept.map((e) => e.path!));
      _fail('Could not save the photos on this device.'.tr);
    }
    return kept;
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
      photos: visit.photos,
    );
  }

  // ==========================================================
  // VALIDATION HELPERS
  // ==========================================================

  Never _fail(String message) =>
      throw ServerException(ErrorMessageModel(statusMessage: message));

  void _requireAdmin() {
    if (AppSession.isTechnician) _fail('Only the admin can do this.'.tr);
  }

  /// Technicians act only on their own visits, from where they really are.
  /// Returns the location to log, or null for the admin.
  GModelGeoPoint? _checkFieldProof(
      VisitDetailModel visit, _FieldProof? proof) {
    final photos = proof?.photoPaths ?? const <String>[];

    if (!AppSession.isTechnician) {
      if (photos.isNotEmpty) _fail('Only technicians can add visit photos.'.tr);
      return null;
    }

    if (!VisitRules.isOwnVisit(visit)) {
      _fail('This visit is not assigned to you.'.tr);
    }

    final location = proof?.location;
    if (location == null || !location.isValid) {
      _fail('Your current location is required for this action.'.tr);
    }

    final capturedAt = location.capturedAt;
    if (capturedAt == null ||
        DateTime.now().difference(capturedAt) > VisitRules.maxLocationAge) {
      _fail('Your location is out of date. Refresh it and try again.'.tr);
    }

    if (photos.isNotEmpty && proof?.photoKind == null) {
      _fail('Photos cannot be added at this step.'.tr);
    }
    if (photos.length > VisitRules.maxPhotosPerAction) {
      _fail('You can add up to {0} photos at a time.'
          .trArgs([VisitRules.maxPhotosPerAction]));
    }

    return location;
  }

  double? _distanceFromSite(VisitDetailModel visit, GModelGeoPoint location) {
    if (!VisitRules.siteHasCoordinates(visit) || !location.isValid) {
      return null;
    }
    return GFunLocation.distance(
        location, visit.site!.latitude!, visit.site!.longitude!);
  }

  /// Work can only start at the site. A site without coordinates cannot be
  /// checked; the technician's location is still logged for the admin.
  void _checkOnSite(VisitDetailModel visit, GModelGeoPoint location) {
    final distance = _distanceFromSite(visit, location);
    if (distance == null) return;

    if (distance > VisitRules.maxStartDistanceMeters) {
      _fail('You are {0} from the site. Move within {1} to start work.'.trArgs([
        GFunLocation.distanceText(distance),
        GFunLocation.distanceText(VisitRules.maxStartDistanceMeters),
      ]));
    }
  }

  void _checkReason(String? reason, {required bool required}) {
    final length = reason?.trim().length ?? 0;

    if (required && length < VisitRules.minReasonLength) {
      _fail('Please give a reason of at least {0} characters.'.trArgs([VisitRules.minReasonLength]));
    }

    if (length > VisitRules.maxReasonLength) {
      _fail('The reason cannot exceed {0} characters.'.trArgs([VisitRules.maxReasonLength]));
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
        _fail('{0} is already booked on {1} at {2}.'.trArgs([technician.name ?? 'This technician'.tr, other.visitNumber ?? 'another visit'.tr, _dateTime(otherStart)]));
      }
    }
  }

  /// Money is validated in cents to avoid floating point errors.
  int _cents(num? value) {
    if (value == null || !value.toDouble().isFinite || value < 0) {
      _fail('A valid, non-negative amount is required.'.tr);
    }

    final amount = value.toDouble() * 100;

    if ((amount - amount.round()).abs() > 0.000001) {
      _fail('Amounts must have at most 2 decimal places.'.tr);
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
    if (visitID.trim().isEmpty) _fail('Visit ID is required.'.tr);

    final matches = visits.where((e) => e.id == visitID).toList();

    if (matches.isEmpty) _fail('This visit no longer exists.'.tr);
    if (matches.length > 1) _fail('This visit is duplicated in storage.'.tr);

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
      _fail('This visit is linked to more than one invoice.'.tr);
    }

    return matches.firstOrNull;
  }

  TechnicianModel _findTechnician(String? technicianID) {
    final technician = _readList(_techniciansKey, TechnicianDetailModel.fromJson)
        .where((e) => e.id != null && e.id == technicianID)
        .firstOrNull;

    if (technician == null) _fail('This technician no longer exists.'.tr);

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
    if (!saved) _fail('Could not save the changes locally.'.tr);
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

  String _siteText(GModelSite site) => [site.city?.name?.tr, site.addressDetail]
      .where((e) => (e ?? '').trim().isNotEmpty)
      .join(' - ');
}
