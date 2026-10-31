import 'dart:async';
import 'dart:convert';

import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/core/local/local_pref.dart';
import 'package:visit_proof/core/network/error/exception.dart';
import 'package:visit_proof/core/network/error/error_message_model.dart';
import 'package:visit_proof/core/network/error/handle_logic_errors.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/core/utils/general_functions.dart/g_fun_token.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_history_model.dart';
import '../../domain/usecases/visit_detail_actions_uc.dart';

abstract class BaseVisitDetailRemoteDataSource {
  Future<VisitDetailModel> getVisitDetail(GetVisitDetailParameters parameters);
  Future<VisitDetailModel> updateVisit(UpdateVisitParameters parameters);
  Future<VisitDetailModel> changeVisitStatus(
      ChangeVisitStatusParameters parameters);
  Future<VisitDetailModel> assignTechnician(
      AssignVisitTechnicianParameters parameters);
  Future<VisitDetailModel> unassignTechnician(
      UnassignVisitTechnicianParameters parameters);
  Future<VisitDetailModel> addAdminComment(
      AddVisitCommentParameters parameters);
}

/// Local prototype with existing models only. ServerException errors pass
/// through HandleLogicErrors unchanged. Not secure storage / not ACID.
class VisitDetailRemoteDataSource extends BaseVisitDetailRemoteDataSource {
  static Future<void> _queue = Future<void>.value();
  static const _visits = 'visits';
  static const _invoices = 'invoices';
  static final _localAdmin = VisitHistoryActorModel(
      id: 'local-admin', name: 'Local Admin', role: 'Admin');

  Never _fail(String message) =>
      throw ServerException(ErrorMessageModel(statusMessage: message));

  Future<T> _locked<T>(Future<T> Function() action) async {
    final previous = _queue;
    final gate = Completer<void>();
    _queue = gate.future;
    await previous;
    try {
      return await action();
    } finally {
      gate.complete();
    }
  }

  List<VisitDetailModel> _readVisits() =>
      (LocalPref.sharedPreferences.getStringList(_visits) ?? <String>[])
          .map((e) => VisitDetailModel.fromJson(
              Map<String, dynamic>.from(jsonDecode(e) as Map)))
          .toList();

  List<InvoiceDetailModel> _readInvoices() =>
      (LocalPref.sharedPreferences.getStringList(_invoices) ?? <String>[])
          .map((e) => InvoiceDetailModel.fromJson(
              Map<String, dynamic>.from(jsonDecode(e) as Map)))
          .toList();

  int _index(List<VisitDetailModel> items, String? id) {
    if (id == null || id.trim().isEmpty) _fail('Visit ID is required.');
    final matches = items.where((v) => v.id == id).length;
    if (matches != 1) _fail('Visit not found or duplicated: $id');
    return items.indexWhere((v) => v.id == id);
  }

  int _cents(num? value, {bool nullableZero = false}) {
    if (nullableZero && value == null) return 0;
    final d = value?.toDouble();
    if (d == null ||
        !d.isFinite ||
        d < 0 ||
        d * 100 > 9e15 ||
        ((d * 100) - (d * 100).round()).abs() > .000001) {
      _fail(
          'A valid non-negative amount with up to 2 decimal places is required.');
    }
    return (d * 100).round();
  }

  void _basic(VisitDetailModel v) {
    if (v.client?.id == null || (v.client!.id ?? '').trim().isEmpty) {
      _fail('Client is required.');
    }
    if (v.site == null ||
        ((v.site?.addressDetail ?? '').trim().isEmpty &&
            (v.site?.latitude == null || v.site?.longitude == null))) {
      _fail('Visit site is required.');
    }
    if ((v.serviceName ?? '').trim().isEmpty) _fail('Service is required.');
    if (v.startDate == null) _fail('Visit date and time are required.');
    if ((v.durationInMin ?? 0) <= 0) {
      _fail('Duration must be greater than zero.');
    }
    if (v.price == null) _fail('Visit price is required.');
    _cents(v.price);
  }

  void _validFor(VisitDetailModel v) {
    if (v.status == null) _fail('Visit status is required.');
    if (v.status != VisitStatus.draft && v.status != VisitStatus.cancel) {
      _basic(v);
    }
    if ((v.status == VisitStatus.assigned ||
            v.status == VisitStatus.onWay ||
            v.status == VisitStatus.inProgress ||
            v.status == VisitStatus.completed) &&
        (v.technicianModel?.id ?? '').trim().isEmpty) {
      _fail('This status requires an assigned technician.');
    }
    if (v.status == VisitStatus.scheduled && v.technicianModel != null) {
      _fail('Scheduled visits must have no technician.');
    }
    if (v.status == VisitStatus.draft && v.technicianModel != null) {
      _fail('Assign the technician using Assign Visit, not while Draft.');
    }
  }

  void _noConflict(List<VisitDetailModel> visits, VisitDetailModel proposed) {
    final techID = proposed.technicianModel?.id;
    if (techID == null ||
        proposed.startDate == null ||
        (proposed.durationInMin ?? 0) <= 0) {
      return;
    }
    if ({VisitStatus.completed, VisitStatus.cancel, VisitStatus.draft}
        .contains(proposed.status)) {
      return;
    }
    final start = proposed.startDate!;
    final end = start.add(Duration(minutes: proposed.durationInMin!));
    for (final other in visits) {
      if (other.id == proposed.id ||
          other.technicianModel?.id != techID ||
          other.startDate == null ||
          (other.durationInMin ?? 0) <= 0 ||
          {VisitStatus.completed, VisitStatus.cancel, VisitStatus.draft}
              .contains(other.status)) {
        continue;
      }
      final otherEnd =
          other.startDate!.add(Duration(minutes: other.durationInMin!));
      if (start.isBefore(otherEnd) && other.startDate!.isBefore(end)) {
        _fail(
            'Technician has an overlapping visit (${other.visitNumber ?? other.id}).');
      }
    }
  }

  bool _different(Object? a, Object? b) => jsonEncode(a) != jsonEncode(b);
  String _field(dynamic v) => jsonEncode(v);
  String _auditDiff(VisitDetailModel before, VisitDetailModel after) {
    final a = before.toJson(), b = after.toJson();
    final keys = a.keys.where((k) => _different(a[k], b[k])).toList();
    return keys.map((k) => '$k: ${_field(a[k])} -> ${_field(b[k])}').join('; ');
  }

  VisitDetailModel _addHistory(VisitDetailModel visit, String description,
      {String? reason, VisitHistoryActorModel? actor}) {
    final logs = List<VisitHistoryModel>.from(visit.history ?? []);
    logs.add(VisitHistoryModel(
      id: GFunToken.generateRandomId(),
      visitId: visit.id,
      recordedAt: DateTime.now(),
      actor: actor ?? _localAdmin,
      description: description,
      reason: reason,
    ));
    return visit.copyWith(history: logs);
  }

  // Existing VisitDetailModel.copyWith cannot set technicianModel to null.
  VisitDetailModel _withoutTechnician(VisitDetailModel v, VisitStatus status) =>
      VisitDetailModel(
        id: v.id,
        visitNumber: v.visitNumber,
        status: status,
        serviceName: v.serviceName,
        client: v.client,
        site: v.site,
        category: v.category,
        price: v.price,
        durationInMin: v.durationInMin,
        checkList: v.checkList,
        problemDescription: v.problemDescription,
        notes: v.notes,
        priority: v.priority,
        startDate: v.startDate,
        technicianModel: null,
        history: v.history,
        paymentStatus: v.paymentStatus,
        invoiceID: v.invoiceID,
        requireBeforeWorkPhotos: v.requireBeforeWorkPhotos,
        requireAfterWorkPhotos: v.requireAfterWorkPhotos,
      );

  int _linkedInvoiceIndex(
      List<InvoiceDetailModel> invoices, VisitDetailModel visit) {
    if ((visit.invoiceID ?? '').trim().isEmpty) {
      _fail('Visit must be linked to one invoice.');
    }
    final matches = invoices
        .where((e) => e.id == visit.invoiceID && e.visitId == visit.id)
        .toList();
    if (matches.length != 1 ||
        invoices.where((e) => e.visitId == visit.id).length != 1) {
      _fail(
          'The visit/invoice one-to-one relationship is missing or inconsistent.');
    }
    return invoices.indexWhere((e) => e.id == visit.invoiceID);
  }

  Future<void> _save(
      List<VisitDetailModel> visits, List<InvoiceDetailModel> invoices,
      {required bool writeInvoice}) async {
    final prefs = LocalPref.sharedPreferences;
    final oldVisits = prefs.getStringList(_visits);
    final oldInvoices = prefs.getStringList(_invoices);
    final encodedVisits = visits.map((e) => jsonEncode(e.toJson())).toList();
    final encodedInvoices =
        invoices.map((e) => jsonEncode(e.toJson())).toList();
    try {
      // Invoice first, visit second. Best effort rollback, NOT crash atomicity.
      if (writeInvoice &&
          !await prefs.setStringList(_invoices, encodedInvoices)) {
        _fail('Could not save linked invoice.');
      }
      if (!await prefs.setStringList(_visits, encodedVisits)) {
        _fail('Could not save visit.');
      }
    } catch (_) {
      try {
        if (oldInvoices == null) {
          await prefs.remove(_invoices);
        } else {
          await prefs.setStringList(_invoices, oldInvoices);
        }
        if (oldVisits == null) {
          await prefs.remove(_visits);
        } else {
          await prefs.setStringList(_visits, oldVisits);
        }
      } catch (_) {/* No ACID guarantee in SharedPreferences */}
      rethrow;
    }
  }

  // Every mutation reads the latest stored values and captures invoice changes
  // in a per-request snapshot.
  Future<VisitDetailModel> _apply(
      String visitID,
      VisitDetailModel Function(VisitDetailModel current,
              List<VisitDetailModel> visits, List<InvoiceDetailModel> invoices)
          change,
      {String? reason,
      VisitHistoryActorModel? actor,
      required String action}) async {
    return _locked(() async {
      final visits = _readVisits();
      final invoices = _readInvoices();
      final index = _index(visits, visitID);
      final current = visits[index];
      final invoiceIndex = _linkedInvoiceIndex(invoices, current);
      final originalInvoice = jsonEncode(invoices[invoiceIndex].toJson());
      final updated = change(current, visits, invoices);
      if (updated.id != current.id ||
          updated.visitNumber != current.visitNumber ||
          updated.invoiceID != current.invoiceID) {
        _fail('Visit and invoice identifiers cannot change.');
      }
      _validFor(updated);
      _noConflict(visits, updated);
      final diff = _auditDiff(current, updated);
      if (diff.isEmpty && action != 'Comment') _fail('No changes detected.');
      final saved =
          _addHistory(updated, '$action | $diff', reason: reason, actor: actor);
      visits[index] = saved;
      final invoiceChanged =
          jsonEncode(invoices[invoiceIndex].toJson()) != originalInvoice;
      await _save(visits, invoices, writeInvoice: invoiceChanged);
      return saved;
    });
  }

  @override
  Future<VisitDetailModel> getVisitDetail(
      GetVisitDetailParameters parameters) async {
    return await HandleLogicErrors<VisitDetailModel>(fun: () async {
      await Future.delayed(const Duration(milliseconds: 180));
      return _locked(() async {
        final all = _readVisits();
        return all[_index(all, parameters.visitID)];
      });
    }).checkLogicErrors();
  }

  @override
  Future<VisitDetailModel> updateVisit(UpdateVisitParameters parameters) async {
    return await HandleLogicErrors<VisitDetailModel>(fun: () async {
      final updated = await _apply(parameters.original.id ?? '',
          (current, visits, invoices) {
        if (jsonEncode(current.toJson()) !=
            jsonEncode(parameters.original.toJson())) {
          _fail('Visit was changed elsewhere. Refresh before editing.');
        }
        if (current.status != parameters.updated.status ||
            current.id != parameters.updated.id ||
            current.invoiceID != parameters.updated.invoiceID ||
            current.visitNumber != parameters.updated.visitNumber) {
          _fail(
              'Status and IDs cannot be changed by Edit. Use dedicated actions.');
        }
        if ((parameters.updated.notes ?? '').length > 3000) {
          _fail('Notes cannot exceed 3000 characters.');
        }
        if ((parameters.updated.problemDescription ?? '').length > 1000) {
          _fail('Problem description cannot exceed 1000 characters.');
        }
        if ((parameters.updated.checkList ?? []).length > 100 ||
            (parameters.updated.checkList ?? [])
                .any((e) => e.trim().isEmpty || e.length > 500)) {
          _fail(
              'Checklist allows up to 100 non-empty items of at most 500 characters.');
        }
        final before = current.toJson(), after = parameters.updated.toJson();
        final changed = before.keys
            .where((key) => _different(before[key], after[key]))
            .toSet();
        // Changes to the audit history are never allowed from Edit.
        // Prevent tampering with finance/history/technician via generic update.
        if (changed.contains('paymentStatus') ||
            changed.contains('technician') ||
            changed.contains('history')) {
          _fail('Payment, technician and history require their own actions.');
        }
        const basic = {
          'client',
          'site',
          'serviceName',
          'category',
          'price',
          'duration',
          'checkList',
          'problem',
          'notes',
          'priority',
          'startDate',
          'requireBeforeWorkPhotos',
          'requireAfterWorkPhotos'
        };
        if (!basic.containsAll(changed)) {
          _fail('Unsupported visit field change.');
        }
        final status = current.status;
        Set<String> allowed;
        if (status == VisitStatus.draft) {
          allowed = basic;
        } else if (status == VisitStatus.scheduled) {
          allowed = {
            'site',
            'serviceName',
            'category',
            'price',
            'duration',
            'checkList',
            'problem',
            'notes',
            'priority',
            'startDate',
            'requireBeforeWorkPhotos',
            'requireAfterWorkPhotos'
          };
        } else if (status == VisitStatus.assigned) {
          allowed = {
            'price',
            'duration',
            'checkList',
            'problem',
            'notes',
            'priority',
            'startDate',
            'requireBeforeWorkPhotos',
            'requireAfterWorkPhotos'
          };
        } else if (status == VisitStatus.onWay) {
          allowed = {'price', 'problem', 'notes', 'priority'};
        } else if (status == VisitStatus.inProgress) {
          allowed = {'price', 'notes', 'priority'};
        } else {
          allowed = {};
        }
        if (!allowed.containsAll(changed)) {
          _fail(
              'Current Visit Status does not allow editing one or more selected fields.');
        }
        if (status == VisitStatus.scheduled &&
            changed.contains('category') &&
            !changed.contains('serviceName')) {
          _fail('Category cannot change without changing the service.');
        }
        if (status == VisitStatus.inProgress || status == VisitStatus.onWay) {
          if (changed.contains('notes') &&
              !(parameters.updated.notes ?? '')
                  .startsWith(current.notes ?? '')) {
            _fail('Notes are append-only after technician starts travelling.');
          }
        }
        final priceChanged = changed.contains('price');
        if (priceChanged) {
          if ({VisitStatus.onWay, VisitStatus.inProgress}.contains(status)) {
            if (!parameters.allowPriceOverride ||
                (parameters.reason ?? '').trim().length < 8) {
              _fail(
                  'Price changes now require approval and an audit reason of at least 8 characters.');
            }
          }
        }
        if (changed.contains('startDate') &&
            {VisitStatus.scheduled, VisitStatus.assigned}.contains(status) &&
            parameters.updated.startDate != null &&
            parameters.updated.startDate!.isBefore(DateTime.now())) {
          _fail('Rescheduled visits must start in the future.');
        }
        if (changed.contains('site') ||
            changed.contains('client') ||
            changed.contains('price')) {
          final invIdx = _linkedInvoiceIndex(invoices, current);
          final inv = invoices[invIdx];
          final oldSubtotal = _cents(inv.subtotal, nullableZero: true);
          final oldDiscount = _cents(inv.discountAmount, nullableZero: true);
          final oldTax = _cents(inv.taxAmount, nullableZero: true);
          final oldTotal = _cents(inv.totalAmount, nullableZero: true);
          final oldPaid = _cents(inv.paidAmount, nullableZero: true);
          final oldRemaining = _cents(inv.remainingAmount, nullableZero: true);
          if (oldSubtotal - oldDiscount + oldTax != oldTotal ||
              oldPaid + oldRemaining != oldTotal) {
            _fail(
                'Linked invoice has inconsistent amounts. Correct it before editing the visit.');
          }
          if (inv.issueDate != null ||
              inv.paymentStatus != PaymentStatus.unpaid ||
              (inv.paidAmount ?? 0) != 0) {
            _fail(
                'Issued or paid invoice prevents editing client, site or visit price.');
          }
          num subtotal = inv.subtotal ?? 0;
          num total = inv.totalAmount ?? 0;
          if (priceChanged) {
            final nextPrice = _cents(parameters.updated.price);
            final discount = _cents(inv.discountAmount, nullableZero: true);
            final tax = _cents(inv.taxAmount, nullableZero: true);
            if (discount > nextPrice) {
              _fail(
                  'Discount exceeds the new visit price. Adjust invoice discount first.');
            }
            subtotal = nextPrice / 100;
            total = (nextPrice - discount + tax) / 100;
          }
          invoices[invIdx] = inv.copyWith(
              client: parameters.updated.client,
              site: parameters.updated.site,
              subtotal: subtotal,
              totalAmount: total,
              remainingAmount: total);
        }
        return parameters.updated;
      },
          reason: parameters.reason,
          actor: parameters.actor,
          action: 'Admin edited visit');
      await AppToasts.showMessage('Visit updated successfully');
      return updated;
    }).checkLogicErrors();
  }

  @override
  Future<VisitDetailModel> changeVisitStatus(
      ChangeVisitStatusParameters parameters) async {
    return await HandleLogicErrors<VisitDetailModel>(fun: () async {
      final updated = await _apply(parameters.visitID, (v, visits, invoices) {
        final from = v.status, to = parameters.status;
        const transitions = <VisitStatus, Set<VisitStatus>>{
          VisitStatus.draft: {
            VisitStatus.scheduled,
            VisitStatus.assigned,
            VisitStatus.cancel
          },
          VisitStatus.scheduled: {
            VisitStatus.draft,
            VisitStatus.assigned,
            VisitStatus.cancel
          },
          VisitStatus.assigned: {
            VisitStatus.draft,
            VisitStatus.scheduled,
            VisitStatus.onWay,
            VisitStatus.inProgress,
            VisitStatus.cancel
          },
          VisitStatus.onWay: {
            VisitStatus.assigned,
            VisitStatus.scheduled,
            VisitStatus.inProgress,
            VisitStatus.cancel
          },
          VisitStatus.inProgress: {
            VisitStatus.assigned,
            VisitStatus.onWay,
            VisitStatus.completed,
            VisitStatus.cancel
          },
          VisitStatus.completed: {VisitStatus.inProgress},
          VisitStatus.cancel: {VisitStatus.draft, VisitStatus.scheduled},
        };
        if (!(transitions[from]?.contains(to) ?? false)) {
          _fail('Transition $from → $to is not allowed.');
        }
        final reason = (parameters.reason ?? '').trim();
        final special = to == VisitStatus.cancel ||
            from == VisitStatus.completed ||
            from == VisitStatus.cancel ||
            (from == VisitStatus.inProgress && to != VisitStatus.completed) ||
            (from == VisitStatus.onWay &&
                (to == VisitStatus.assigned || to == VisitStatus.scheduled));
        if (special && reason.length < 8) {
          _fail('This transition requires a reason of at least 8 characters.');
        }
        if (from == VisitStatus.inProgress &&
            to == VisitStatus.cancel &&
            !parameters.exceptionalApproval) {
          _fail(
              'Cancellation during work requires exceptional admin approval.');
        }
        if (from == VisitStatus.inProgress &&
            {VisitStatus.assigned, VisitStatus.onWay}.contains(to) &&
            !parameters.exceptionalApproval) {
          _fail('Correction during work requires admin approval.');
        }
        if (from == VisitStatus.assigned &&
            (to == VisitStatus.draft || to == VisitStatus.scheduled)) {
          _fail('Unassign the technician first using Unassign Visit.');
        }
        if (from == VisitStatus.onWay && to == VisitStatus.scheduled) {
          _fail('First stop the trip and return to Assigned, then Unassign.');
        }
        if (to == VisitStatus.assigned && v.technicianModel == null) {
          _fail('Use Assign Technician to enter Assigned status.');
        }
        if ((to == VisitStatus.scheduled || to == VisitStatus.assigned) &&
            (from == VisitStatus.draft || from == VisitStatus.cancel) &&
            (v.startDate == null || v.startDate!.isBefore(DateTime.now()))) {
          _fail('Scheduled visits must have a future start time.');
        }
        // if (to == VisitStatus.completed) {
        //   // No proof/checklist-results models exist in VisitDetailModel.
        //   // Fail closed instead of claiming evidence was checked.
        //   if (v.requireBeforeWorkPhotos == true || v.requireAfterWorkPhotos == true ||
        //       (v.checkList ?? []).isNotEmpty) {
        //     _fail('Completion requires verified checklist/photo evidence, which the current VisitDetailModel does not store.');
        //   }
        // }
        // Cancellation only changes visit status: financial obligations remain intact.
        // Reactivation preserves the historical cancellation reason.
        if (from == VisitStatus.cancel &&
            (to == VisitStatus.draft || to == VisitStatus.scheduled)) {
          return _withoutTechnician(v, to);
        }
        return v.copyWith(status: to);
      },
          reason: parameters.reason,
          actor: parameters.actor,
          action: 'Admin changed status to ${parameters.status.name}');
      await AppToasts.showMessage('Visit status updated');
      return updated;
    }).checkLogicErrors();
  }

  @override
  Future<VisitDetailModel> assignTechnician(
      AssignVisitTechnicianParameters parameters) async {
    return await HandleLogicErrors<VisitDetailModel>(fun: () async {
      final updated = await _apply(parameters.visitID, (v, visits, invoices) {
        if (v.status != VisitStatus.draft &&
            v.status != VisitStatus.scheduled &&
            v.status != VisitStatus.assigned) {
          _fail(
              'Technician can only be assigned/reassigned before travelling.');
        }
        if ((parameters.technician.id ?? '').trim().isEmpty) {
          _fail('Valid technician ID is required.');
        }
        if (v.technicianModel?.id == parameters.technician.id) {
          _fail('Technician is already assigned.');
        }
        if (v.technicianModel != null &&
            (parameters.reason ?? '').trim().length < 8) {
          _fail(
              'Reassigning a technician requires an audit reason of at least 8 characters.');
        }
        final candidate = v.copyWith(
            technicianModel: parameters.technician,
            status: VisitStatus.assigned);
        _basic(candidate);
        if (candidate.startDate!.isBefore(DateTime.now())) {
          _fail('A technician cannot be assigned to a past visit time.');
        }
        return candidate;
      },
          reason: parameters.reason,
          actor: parameters.actor,
          action: 'Admin assigned technician');
      await AppToasts.showMessage('Technician assignment saved');
      return updated;
    }).checkLogicErrors();
  }

  @override
  Future<VisitDetailModel> unassignTechnician(
      UnassignVisitTechnicianParameters parameters) async {
    return await HandleLogicErrors<VisitDetailModel>(fun: () async {
      final updated = await _apply(parameters.visitID, (v, visits, invoices) {
        if (v.status != VisitStatus.assigned) {
          _fail('Unassign is available only while Assigned.');
        }
        if (v.technicianModel == null) {
          _fail('There is no technician to remove.');
        }
        if (parameters.destination != VisitStatus.scheduled &&
            parameters.destination != VisitStatus.draft) {
          _fail('Unassign destination must be Scheduled or Draft.');
        }
        if ((parameters.reason ?? '').trim().length < 8) {
          _fail('Unassignment needs a reason of at least 8 characters.');
        }
        return _withoutTechnician(v, parameters.destination);
      },
          reason: parameters.reason,
          actor: parameters.actor,
          action: 'Admin unassigned technician');
      await AppToasts.showMessage('Technician unassigned');
      return updated;
    }).checkLogicErrors();
  }

  @override
  Future<VisitDetailModel> addAdminComment(
      AddVisitCommentParameters parameters) async {
    return await HandleLogicErrors<VisitDetailModel>(fun: () async {
      final comment = parameters.comment.trim();
      if (comment.length < 2 || comment.length > 1000) {
        _fail('Comment must be 2–1000 characters.');
      }
      final updated = await _locked(() async {
        final visits = _readVisits();
        final idx = _index(visits, parameters.visitID);
        final next = _addHistory(visits[idx], 'Admin comment: $comment',
            actor: parameters.actor);
        visits[idx] = next;
        // Comments do not change invoice. Preserve existing invoice snapshot.
        final ok = await LocalPref.sharedPreferences.setStringList(
            _visits, visits.map((e) => jsonEncode(e.toJson())).toList());
        if (!ok) _fail('Could not save comment.');
        return next;
      });
      await AppToasts.showMessage('Comment added');
      return updated;
    }).checkLogicErrors();
  }
}
