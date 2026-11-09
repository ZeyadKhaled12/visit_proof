import 'package:visit_proof/core/network/app_latency.dart';
import 'package:visit_proof/configs/app_language.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:visit_proof/app/app.dart';
import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/core/local/local_pref.dart';
import 'package:visit_proof/core/network/error/handle_logic_errors.dart';
import 'package:visit_proof/core/network/error/error_message_model.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/general_functions.dart/g_fun_token.dart';
import 'package:visit_proof/core/utils/enums/payment_entry_status_enum.dart';
import 'package:visit_proof/core/utils/enums/payment_method_enum.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';

import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_payment_history_model.dart';
import 'package:visit_proof/features/invoices/domain/usecases/get_create_invoice_uc.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_history_model.dart';

import '../../../../core/local/local_photos.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/utils/enums/photo_kind_enum.dart';
import '../../../../core/utils/general_functions.dart/g_fun_location.dart';
import '../../../../core/utils/general_models/g_model_geo_point.dart';
import '../../../visit_detail/domain/rules/visit_rules.dart';
import '../../../visits/data/models/visit_detail_models/visit_photo_model.dart';
import '../../../../core/network/error/exception.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/usecases/get_invoice_detail_uc.dart';
import '../../domain/usecases/get_payments_uc.dart';
import '../../domain/usecases/issue_invoice_uc.dart';
import '../../domain/usecases/record_payment_uc.dart';
import '../../domain/usecases/refund_payment_uc.dart';
import '../../domain/usecases/review_payment_uc.dart';
import '../../domain/usecases/update_draft_invoice_uc.dart';

// ============================================================
// BASE DATA SOURCE
// ============================================================

abstract class BaseInvoicesRemoteDataSource {
  Future<List<InvoiceDetailModel>> getInvoices(NoParameters parameters);

  Future<InvoiceDetailModel> getOrCreateInvoice(
      GetCreateInvoiceParameters parameters);

  Future<InvoiceDetailModel> getInvoiceDetail(
      GetInvoiceDetailParameters parameters);

  Future<InvoiceDetailModel> issueInvoice(IssueInvoiceParameters parameters);

  Future<InvoiceDetailModel> updateDraftInvoice(
      UpdateDraftInvoiceParameters parameters);

  Future<InvoiceDetailModel> recordPayment(RecordPaymentParameters parameters);

  Future<InvoiceDetailModel> refundPayment(RefundPaymentParameters parameters);

  Future<InvoiceDetailModel> reviewPayment(ReviewPaymentParameters parameters);

  Future<List<InvoicePaymentHistoryModel>> getPayments(
      GetPaymentsParameters parameters);
}

// ============================================================
// IMPLEMENTATION
// ============================================================

class InvoicesRemoteDataSource extends BaseInvoicesRemoteDataSource {
  static const String _invoicesKey = 'invoices';
  static const String _visitsKey = 'visits';
  static const String _paymentsKey = 'invoice_payments';

  // Serializes mutations within the current Dart isolate.
  // SharedPreferences is for local testing, not ACID transactions.
  static Future<void> _writeQueue = Future<void>.value();

  /// Who is credited in invoice history and payments.
  static VisitHistoryActorModel get _demoActor => AppSession.actor;

  // ==========================================================
  // LOCAL STORAGE HELPERS
  // ==========================================================

  Future<T> _exclusive<T>(
    Future<T> Function() action,
  ) async {
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

  List<InvoiceDetailModel> _readInvoices(
    SharedPreferences preferences,
  ) {
    final list = preferences.getStringList(_invoicesKey) ?? <String>[];

    return list
        .map(
          (e) => InvoiceDetailModel.fromJson(
            Map<String, dynamic>.from(
              jsonDecode(e) as Map,
            ),
          ),
        )
        .toList();
  }

  List<VisitDetailModel> _readVisits(
    SharedPreferences preferences,
  ) {
    final list = preferences.getStringList(_visitsKey) ?? <String>[];

    return list
        .map(
          (e) => VisitDetailModel.fromJson(
            Map<String, dynamic>.from(
              jsonDecode(e) as Map,
            ),
          ),
        )
        .toList();
  }

  List<InvoicePaymentHistoryModel> _readPayments(
    SharedPreferences preferences,
  ) {
    final list = preferences.getStringList(_paymentsKey) ?? <String>[];

    return list
        .map(
          (e) => InvoicePaymentHistoryModel.fromJson(
            Map<String, dynamic>.from(
              jsonDecode(e) as Map,
            ),
          ),
        )
        .toList();
  }

  Future<void> _save({
    required List<InvoiceDetailModel> invoices,
    required List<VisitDetailModel> visits,
    required List<InvoicePaymentHistoryModel> payments,
  }) async {
    final preferences = LocalPref.sharedPreferences;

    // Best-effort rollback if a preference write fails.
    // Not crash-safe or equivalent to a database transaction.
    final oldInvoices = preferences.getStringList(_invoicesKey);
    final oldVisits = preferences.getStringList(_visitsKey);
    final oldPayments = preferences.getStringList(_paymentsKey);

    try {
      final paymentsSaved = await preferences.setStringList(
        _paymentsKey,
        payments.map((e) => jsonEncode(e.toJson())).toList(),
      );

      if (!paymentsSaved) {
        throw ServerException(
          ErrorMessageModel(
            statusMessage: 'Could not save payments.'.tr,
          ),
        );
      }

      final visitsSaved = await preferences.setStringList(
        _visitsKey,
        visits.map((e) => jsonEncode(e.toJson())).toList(),
      );

      if (!visitsSaved) {
        throw ServerException(
          ErrorMessageModel(
            statusMessage: 'Could not save visits.'.tr,
          ),
        );
      }

      final invoicesSaved = await preferences.setStringList(
        _invoicesKey,
        invoices.map((e) => jsonEncode(e.toJson())).toList(),
      );

      if (!invoicesSaved) {
        throw ServerException(
          ErrorMessageModel(
            statusMessage: 'Could not save invoices.'.tr,
          ),
        );
      }
    } catch (_) {
      try {
        if (oldPayments == null) {
          await preferences.remove(_paymentsKey);
        } else {
          await preferences.setStringList(
            _paymentsKey,
            oldPayments,
          );
        }

        if (oldVisits == null) {
          await preferences.remove(_visitsKey);
        } else {
          await preferences.setStringList(
            _visitsKey,
            oldVisits,
          );
        }

        if (oldInvoices == null) {
          await preferences.remove(_invoicesKey);
        } else {
          await preferences.setStringList(
            _invoicesKey,
            oldInvoices,
          );
        }
      } catch (_) {
        // The local demo store may require manual recovery.
      }

      rethrow;
    }
  }

  // ==========================================================
  // VALIDATION HELPERS
  // ==========================================================

  InvoiceDetailModel _findInvoice(
    List<InvoiceDetailModel> invoices,
    String invoiceId,
  ) {
    final matches = invoices.where((e) => e.id == invoiceId).toList();

    if (matches.length != 1) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Invoice not found or duplicated: {0}'.trArgs([invoiceId]),
        ),
      );
    }

    return matches.single;
  }

  VisitDetailModel _linkedVisit(
    List<VisitDetailModel> visits,
    InvoiceDetailModel invoice,
  ) {
    final matches = visits.where((e) => e.id == invoice.visitId).toList();

    if (matches.length != 1) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'The linked visit is missing from local storage. Save the VisitDetailModel in the "visits" preference first.'.tr,
        ),
      );
    }

    final visit = matches.single;

    if (visit.invoiceID != null && visit.invoiceID != invoice.id) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'This visit is already linked to another invoice.'.tr,
        ),
      );
    }

    if (visit.status == null) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Visit status is missing.'.tr,
        ),
      );
    }

    return visit;
  }

  int _cents(
    num? value, {
    bool allowZero = true,
    bool allowNegative = false,
  }) {
    if (value == null || !value.toDouble().isFinite) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'A valid financial amount is required.'.tr,
        ),
      );
    }

    final amount = value.toDouble() * 100;

    if (!amount.isFinite || amount.abs() > 9000000000000000) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Amount is outside the supported range.'.tr,
        ),
      );
    }

    if ((amount - amount.round()).abs() > 0.000001) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Amounts must have at most 2 decimal places.'.tr,
        ),
      );
    }

    final cents = amount.round();

    if ((!allowNegative && cents < 0) || (!allowZero && cents == 0)) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Amount must be greater than zero.'.tr,
        ),
      );
    }

    return cents;
  }

  void _validFinance(
    InvoiceDetailModel invoice,
  ) {
    if ((invoice.id ?? '').trim().isEmpty ||
        (invoice.visitId ?? '').trim().isEmpty) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Invoice and visit IDs are required.'.tr,
        ),
      );
    }

    if (invoice.paymentStatus == null) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Invoice payment status is missing.'.tr,
        ),
      );
    }

    final total = _cents(invoice.totalAmount);
    final paid = _cents(invoice.paidAmount);
    final remaining = _cents(invoice.remainingAmount);

    final pending = _cents(invoice.pendingAmount ?? 0);

    if (paid > total || remaining != total - paid || pending > remaining) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Invoice totals are inconsistent.'.tr,
        ),
      );
    }

    if ((invoice.paymentStatus == PaymentStatus.unpaid && paid != 0) ||
        (invoice.paymentStatus == PaymentStatus.partiallyPaid &&
            (paid <= 0 || paid >= total)) ||
        (invoice.paymentStatus == PaymentStatus.paid && paid != total)) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Payment status does not match the paid amount.'.tr,
        ),
      );
    }

    final subtotal = _cents(invoice.subtotal);
    final discount = _cents(invoice.discountAmount);
    final tax = _cents(invoice.taxAmount);

    if (discount > subtotal || subtotal - discount + tax != total) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Subtotal, discount, tax and total do not match.'.tr,
        ),
      );
    }

    if ((invoice.currency ?? '').trim().isEmpty) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Invoice currency is required.'.tr,
        ),
      );
    }

    if ((invoice.client?.id ?? '').trim().isEmpty ||
        (invoice.client?.name ?? '').trim().isEmpty) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Invoice client must be complete.'.tr,
        ),
      );
    }

    if (invoice.issueDate != null &&
        invoice.dueDate != null &&
        _day(invoice.dueDate!).isBefore(
          _day(invoice.issueDate!),
        )) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Due date cannot precede issue date.'.tr,
        ),
      );
    }
  }

  PaymentStatus _paymentStatus(
    int paid,
    int total, {
    bool hadRefund = false,
  }) {
    if (paid == 0 && hadRefund) {
      return PaymentStatus.refunded;
    }

    if (paid == 0) {
      return PaymentStatus.unpaid;
    }

    if (paid == total) {
      return PaymentStatus.paid;
    }

    return PaymentStatus.partiallyPaid;
  }

  /// The status after a payment change: a cancelled invoice stays
  /// cancelled, and money waiting for the admin keeps it pending.
  PaymentStatus _statusAfter(
    InvoiceDetailModel invoice, {
    required int paid,
    required int pending,
    bool hadRefund = false,
  }) {
    if (invoice.paymentStatus == PaymentStatus.cancelled) {
      return PaymentStatus.cancelled;
    }

    if (pending > 0) return PaymentStatus.pending;

    return _paymentStatus(
      paid,
      _cents(invoice.totalAmount),
      hadRefund: hadRefund,
    );
  }

  Never _fail(String message) =>
      throw ServerException(ErrorMessageModel(statusMessage: message));

  void _requireAdmin() {
    if (AppSession.isTechnician) _fail('Only the admin can do this.'.tr);
  }

  bool _isOwnVisit(VisitDetailModel visit) =>
      AppSession.technicianId != null &&
      visit.technicianModel?.id == AppSession.technicianId;

  DateTime _day(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day,
    );
  }

  String _uniqueId(String prefix) {
    return '$prefix-${GFunToken.generateRandomId()}';
  }

  // ==========================================================
  // GET OR CREATE INVOICE
  // ==========================================================

  @override
  Future<InvoiceDetailModel> getOrCreateInvoice(
    GetCreateInvoiceParameters parameters,
  ) async {
    return await HandleLogicErrors<InvoiceDetailModel>(
      fun: () async {
        await Future.delayed(AppLatency.local);
        _requireAdmin();

        return await _exclusive(() async {
          final invoice = parameters.invoice;

          if ((invoice.id ?? '').trim().isEmpty ||
              (invoice.visitId ?? '').trim().isEmpty) {
            throw ServerException(
              ErrorMessageModel(
                statusMessage: 'Invoice and visit IDs are required.'.tr,
              ),
            );
          }

          final preferences = LocalPref.sharedPreferences;
          final invoices = _readInvoices(preferences);

          final existing = invoices.where((e) => e.id == invoice.id).toList();

          if (existing.isNotEmpty) {
            final stored = _findInvoice(
              invoices,
              invoice.id!,
            );

            if (stored.visitId != invoice.visitId) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage:
                      'Cannot change the visit of an existing invoice.'.tr,
                ),
              );
            }

            return stored;
          }

          if (invoices.any(
            (e) => e.visitId == invoice.visitId,
          )) {
            throw ServerException(
              ErrorMessageModel(
                statusMessage: 'Only one invoice is allowed per visit.'.tr,
              ),
            );
          }

          invoices.insert(0, invoice);

          final visits = _readVisits(preferences);
          final payments = _readPayments(preferences);

          // DEMO ONLY:
          // Existing dummy invoices may contain paidAmount
          // without a payment history.
          //
          // Create one opening balance entry for local testing.
          // This is not proof of a real payment.

          final isPaidSnapshot = invoice.paymentStatus == PaymentStatus.paid ||
              invoice.paymentStatus == PaymentStatus.partiallyPaid;

          if (isPaidSnapshot &&
              (invoice.paidAmount ?? 0) > 0 &&
              !payments.any(
                (e) => e.invoiceId == invoice.id,
              )) {
            try {
              _validFinance(invoice);

              payments.add(
                InvoicePaymentHistoryModel(
                  id: _uniqueId('demo-opening'),
                  invoiceId: invoice.id,
                  paymentDate: invoice.issueDate ?? DateTime.now(),
                  paymentAmount: invoice.paidAmount,
                  paymentMethod: PaymentMethod.other,
                  collectedBy: _demoActor,
                  referenceNumber: 'OPENING-${invoice.id}',
                  notes: 'DEMO OPENING BALANCE: imported snapshot, not a verified payment transaction.'.tr,
                ),
              );
            } on ServerException {
              // Invalid dummy invoices remain viewable.
              // Financial operations will fail validation.
            }
          }

          await _save(
            invoices: invoices,
            visits: visits,
            payments: payments,
          );

          return invoice;
        });
      },
    ).checkLogicErrors();
  }

  // ==========================================================
  // GET INVOICE DETAIL
  // ==========================================================

  @override
  Future<InvoiceDetailModel> getInvoiceDetail(
    GetInvoiceDetailParameters parameters,
  ) async {
    return await HandleLogicErrors<InvoiceDetailModel>(
      fun: () async {
        await Future.delayed(AppLatency.local);

        return await _exclusive(() async {
          if (parameters.invoiceId.trim().isEmpty) {
            throw ServerException(
              ErrorMessageModel(
                statusMessage: 'Invoice ID is required.'.tr,
              ),
            );
          }

          final preferences = LocalPref.sharedPreferences;
          final invoice = _findInvoice(
            _readInvoices(preferences),
            parameters.invoiceId,
          );

          if (AppSession.isTechnician &&
              !_readVisits(preferences).any(
                (e) => e.id == invoice.visitId && _isOwnVisit(e),
              )) {
            _fail('This visit is not assigned to you.'.tr);
          }

          return invoice;
        });
      },
    ).checkLogicErrors();
  }

  // ==========================================================
  // SHARED INVOICE UPDATE LOGIC
  // ==========================================================

  Future<InvoiceDetailModel> _change(
    String invoiceId, {
    required String description,
    String? reason,
    VisitHistoryActorModel? actor,
    String Function()? describe,
    GModelGeoPoint? location,
    Future<List<VisitPhotoModel>> Function(VisitDetailModel visit)? keepPhotos,
    required InvoiceDetailModel Function(
      InvoiceDetailModel invoice,
      VisitDetailModel visit,
      List<InvoicePaymentHistoryModel> ledger,
    ) edit,
  }) async {
    return await _exclusive(() async {
      final preferences = LocalPref.sharedPreferences;

      final invoices = _readInvoices(preferences);
      final visits = _readVisits(preferences);
      final payments = _readPayments(preferences);

      final current = _findInvoice(
        invoices,
        invoiceId,
      );

      final visit = _linkedVisit(
        visits,
        current,
      );

      _validFinance(current);

      final ledger = payments.where((e) => e.invoiceId == invoiceId).toList();

      final ledgerPaid = _ledgerSum(ledger.where((e) => e.countsAsPaid));
      final ledgerPending = _ledgerSum(ledger.where((e) => e.isPending));

      if (ledgerPaid != _cents(current.paidAmount) ||
          ledgerPending != _cents(current.pendingAmount ?? 0)) {
        throw ServerException(
          ErrorMessageModel(
            statusMessage: 'Payment history and paid balance are inconsistent.'.tr,
          ),
        );
      }

      final updated = edit(
        current,
        visit,
        ledger,
      );

      _validFinance(updated);

      if (updated.id != current.id || updated.visitId != current.visitId) {
        throw ServerException(
          ErrorMessageModel(
            statusMessage: 'Invoice identity cannot be changed.'.tr,
          ),
        );
      }

      if (invoices.any(
        (e) => e.id != updated.id && e.visitId == updated.visitId,
      )) {
        throw ServerException(
          ErrorMessageModel(
            statusMessage: 'Only one invoice is allowed per visit.'.tr,
          ),
        );
      }

      if (ledger.any((e) => e.id == null)) {
        throw ServerException(
          ErrorMessageModel(
            statusMessage: 'Payment entry is missing its identifier.'.tr,
          ),
        );
      }

      // Copied only once the change is valid; removed again if saving fails.
      final photos = keepPhotos == null
          ? const <VisitPhotoModel>[]
          : await keepPhotos(visit);
      final photoPaths = photos.map((e) => e.path!).toList();

      // Append new payment entries (with this change's photos);
      // a reviewed entry replaces its old copy.
      for (final payment in ledger) {
        final index = payments.indexWhere((e) => e.id == payment.id);
        if (index == -1) {
          payments.add(photoPaths.isEmpty
              ? payment
              : payment.copyWith(photos: photoPaths));
        } else {
          payments[index] = payment;
        }
      }

      final invoiceIndex = invoices.indexWhere(
        (e) => e.id == invoiceId,
      );

      invoices[invoiceIndex] = updated;

      // Sync the visit's financial status and add history.
      final visitIndex = visits.indexWhere(
        (e) => e.id == visit.id,
      );

      final history = List<VisitHistoryModel>.from(
        visit.history ?? [],
      );

      history.add(
        VisitHistoryModel(
          id: _uniqueId('invoice-event'),
          visitId: visit.id,
          recordedAt: DateTime.now(),
          actor: actor ?? _demoActor,
          description: describe?.call() ?? description,
          reason: reason,
          location: location,
          distanceFromSite: _distanceFromSite(visit, location),
        ),
      );

      visits[visitIndex] = visit.copyWith(
        invoiceID: updated.id,
        paymentStatus: updated.paymentStatus,
        history: history,
        photos: photos.isEmpty ? null : [...?visit.photos, ...photos],
      );

      try {
        await _save(
          invoices: invoices,
          visits: visits,
          payments: payments,
        );
      } catch (_) {
        await LocalPhotos.remove(photoPaths);
        rethrow;
      }

      return updated;
    });
  }

  int _ledgerSum(Iterable<InvoicePaymentHistoryModel> entries) =>
      entries.fold<int>(
        0,
        (sum, payment) =>
            sum +
            _cents(
              payment.paymentAmount,
              allowNegative: true,
            ),
      );

  double? _distanceFromSite(
    VisitDetailModel visit,
    GModelGeoPoint? location,
  ) {
    final site = visit.site;
    if (location == null ||
        !location.isValid ||
        site?.latitude == null ||
        site?.longitude == null) {
      return null;
    }
    return GFunLocation.distance(location, site!.latitude!, site.longitude!);
  }

  /// A technician collects only on their own visit, once the work has
  /// started, from where they really are, with at least one receipt photo.
  void _checkFieldCollection(
    VisitDetailModel visit,
    RecordPaymentParameters parameters,
  ) {
    if (!_isOwnVisit(visit)) {
      _fail('This visit is not assigned to you.'.tr);
    }

    if (visit.status != VisitStatus.inProgress &&
        visit.status != VisitStatus.completed) {
      _fail('You can collect payment once the work has started.'.tr);
    }

    final location = parameters.location;
    if (location == null || !location.isValid) {
      _fail('Your current location is required for this action.'.tr);
    }

    final capturedAt = location.capturedAt;
    if (capturedAt == null ||
        DateTime.now().difference(capturedAt) > VisitRules.maxLocationAge) {
      _fail('Your location is out of date. Refresh it and try again.'.tr);
    }

    if (parameters.photoPaths.isEmpty) {
      _fail('Take at least one photo of the receipt or the payment.'.tr);
    }

    if (parameters.photoPaths.length > VisitRules.maxPhotosPerAction) {
      _fail('You can add up to {0} photos at a time.'
          .trArgs([VisitRules.maxPhotosPerAction]));
    }
  }

  /// Copies the receipt photos next to the visit's other photos.
  Future<List<VisitPhotoModel>> _keepReceipts(
    VisitDetailModel visit,
    List<String> paths,
    GModelGeoPoint? location,
  ) async {
    final kept = <VisitPhotoModel>[];
    try {
      for (final path in paths) {
        final id = GFunToken.generateRandomId();
        kept.add(VisitPhotoModel(
          id: id,
          path: await LocalPhotos.keep(
              tempPath: path, visitID: visit.id!, photoID: id),
          kind: PhotoKind.receipt,
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

  // ==========================================================
  // ISSUE INVOICE
  // ==========================================================

  @override
  Future<InvoiceDetailModel> issueInvoice(
    IssueInvoiceParameters parameters,
  ) async {
    return await HandleLogicErrors<InvoiceDetailModel>(
      fun: () async {
        await Future.delayed(AppLatency.local);

        _requireAdmin();

        final updated = await _change(
          parameters.invoiceId,
          description: 'Invoice issued'.tr,
          reason: parameters.overrideReason,
          edit: (invoice, visit, ledger) {
            if (invoice.issueDate != null ||
                invoice.paymentStatus != PaymentStatus.unpaid ||
                _cents(invoice.paidAmount) != 0) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Only an unpaid draft invoice can be issued.'.tr,
                ),
              );
            }

            if (ledger.isNotEmpty) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'A draft invoice cannot have payment entries.'.tr,
                ),
              );
            }

            if (_cents(invoice.totalAmount) <= 0) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Invoice total must exceed zero.'.tr,
                ),
              );
            }

            if (visit.status == VisitStatus.cancel) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage:
                      'Cannot issue an invoice for a cancelled visit.'.tr,
                ),
              );
            }

            if (visit.status != VisitStatus.completed) {
              if (!parameters.allowEarlyIssue ||
                  (parameters.overrideReason ?? '').trim().length < 8) {
                throw ServerException(
                  ErrorMessageModel(
                    statusMessage:
                        'Complete the visit first, or provide an approved early-issue override with a reason.'.tr,
                  ),
                );
              }
            }

            final now = DateTime.now();

            if (invoice.dueDate != null &&
                _day(invoice.dueDate!).isBefore(
                  _day(now),
                )) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Due date must not be before issue date.'.tr,
                ),
              );
            }

            // Issuing starts the payment term unless a due date was set.
            return invoice.copyWith(
              issueDate: now,
              dueDate: invoice.dueDate ??
                  _day(now).add(
                    Duration(days: App.invoicePaymentTermDays),
                  ),
            );
          },
        );

        await AppToasts.showMessage(
          'Invoice issued successfully'.tr,
        );

        return updated;
      },
    ).checkLogicErrors();
  }

  // ==========================================================
  // UPDATE DRAFT INVOICE
  // ==========================================================

  @override
  Future<InvoiceDetailModel> updateDraftInvoice(
    UpdateDraftInvoiceParameters parameters,
  ) async {
    return await HandleLogicErrors<InvoiceDetailModel>(
      fun: () async {
        await Future.delayed(AppLatency.local);

        _requireAdmin();

        final updated = await _change(
          parameters.invoiceId,
          description: 'Draft invoice updated'.tr,
          reason: parameters.overrideReason,
          edit: (invoice, visit, ledger) {
            if (invoice.issueDate != null ||
                invoice.paymentStatus != PaymentStatus.unpaid ||
                _cents(invoice.paidAmount) != 0 ||
                ledger.isNotEmpty) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Only an unpaid draft can be edited.'.tr,
                ),
              );
            }

            final allowed = visit.status == VisitStatus.draft ||
                visit.status == VisitStatus.scheduled ||
                visit.status == VisitStatus.assigned;

            final overrideEligible = visit.status == VisitStatus.onWay ||
                visit.status == VisitStatus.inProgress;

            if (!allowed &&
                !(overrideEligible &&
                    parameters.allowPriceOverride &&
                    (parameters.overrideReason ?? '').trim().length >= 8)) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage:
                      'The visit status does not allow invoice edits.'.tr,
                ),
              );
            }

            final subtotal = _cents(
              invoice.subtotal,
            );

            final discount = _cents(
              parameters.discountAmount,
            );

            final tax = _cents(
              parameters.taxAmount,
            );

            if (discount > subtotal) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Discount cannot exceed the subtotal.'.tr,
                ),
              );
            }

            final total = subtotal - discount + tax;

            if (total < 0) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Invoice total cannot be negative.'.tr,
                ),
              );
            }

            if (parameters.notes.trim().length > 1000) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Notes cannot exceed 1000 characters.'.tr,
                ),
              );
            }

            return invoice.copyWith(
              discountAmount: discount / 100,
              taxAmount: tax / 100,
              totalAmount: total / 100,
              remainingAmount: total / 100,
              notes: parameters.notes.trim(),
            );
          },
        );

        await AppToasts.showMessage(
          'Draft invoice updated successfully'.tr,
        );
        log('DISCOUNT1: ${updated.discountAmount}');
        return updated;
      },
    ).checkLogicErrors();
  }

  // ==========================================================
  // RECORD PAYMENT
  // ==========================================================

  @override
  Future<InvoiceDetailModel> recordPayment(
      RecordPaymentParameters parameters) async {
    return await HandleLogicErrors<InvoiceDetailModel>(
      fun: () async {
        await Future.delayed(AppLatency.local);

        final field = AppSession.isTechnician;

        if (!field && parameters.photoPaths.isNotEmpty) {
          _fail('Only technicians can add visit photos.'.tr);
        }

        final updated = await _change(
          parameters.invoiceId,
          description: field
              ? 'Technician collected {0} · awaiting admin confirmation'
                  .trArgs([parameters.amount.toStringAsFixed(2)])
              : 'Invoice payment recorded: {0}'
                  .trArgs([parameters.amount.toStringAsFixed(2)]),
          actor: field ? AppSession.actor : parameters.collectedBy,
          location: field ? parameters.location : null,
          keepPhotos: field
              ? (visit) => _keepReceipts(
                  visit, parameters.photoPaths, parameters.location)
              : null,
          edit: (invoice, visit, ledger) {
            if (field) _checkFieldCollection(visit, parameters);

            if (invoice.issueDate == null ||
                (invoice.paymentStatus != PaymentStatus.unpaid &&
                    invoice.paymentStatus != PaymentStatus.partiallyPaid &&
                    invoice.paymentStatus != PaymentStatus.pending)) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage:
                      'Only an issued, collectible invoice can be paid.'.tr,
                ),
              );
            }

            if (visit.status == VisitStatus.draft ||
                visit.status == VisitStatus.cancel) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'This visit cannot accept payments.'.tr,
                ),
              );
            }

            final cents = _cents(
              parameters.amount,
              allowZero: false,
            );

            final pending = _cents(invoice.pendingAmount ?? 0);

            // Money already waiting for confirmation cannot be collected twice.
            final remaining = _cents(invoice.remainingAmount) - pending;

            if (cents > remaining) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: pending > 0
                      ? 'Payment exceeds the remaining balance. {0} is already awaiting confirmation.'
                          .trArgs([pending / 100])
                      : 'Payment exceeds the remaining balance.'.tr,
                ),
              );
            }

            final reference = (parameters.referenceNumber ?? '').trim();

            if (parameters.paymentMethod != PaymentMethod.cash &&
                reference.isEmpty) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Transaction reference is required.'.tr,
                ),
              );
            }

            if (reference.length > 100 ||
                (parameters.notes ?? '').length > 1000) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Reference or notes are too long.'.tr,
                ),
              );
            }

            if (parameters.paymentMethod == PaymentMethod.other &&
                (parameters.notes ?? '').trim().isEmpty) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Explain the selected payment method.'.tr,
                ),
              );
            }

            final duplicateReference = reference.isNotEmpty &&
                ledger.any(
                  (entry) =>
                      entry.referenceNumber?.trim().toLowerCase() ==
                          reference.toLowerCase() &&
                      entry.paymentMethod == parameters.paymentMethod &&
                      (entry.paymentAmount ?? 0) > 0,
                );

            if (duplicateReference) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage:
                      'This transaction reference was already recorded.'.tr,
                ),
              );
            }

            // A field collection waits for the admin; it is not paid yet.
            final paid = _cents(invoice.paidAmount) + (field ? 0 : cents);
            final newPending = pending + (field ? cents : 0);

            final total = _cents(
              invoice.totalAmount,
            );

            ledger.add(
              InvoicePaymentHistoryModel(
                id: _uniqueId('payment'),
                invoiceId: parameters.invoiceId,
                paymentDate: DateTime.now(),
                paymentAmount: cents / 100,
                paymentMethod: parameters.paymentMethod,
                collectedBy: field
                    ? AppSession.actor
                    : (parameters.collectedBy ?? _demoActor),
                referenceNumber: reference.isEmpty ? null : reference,
                notes: (parameters.notes ?? '').trim(),
                status: field
                    ? PaymentEntryStatus.pending
                    : PaymentEntryStatus.confirmed,
                location: field ? parameters.location : null,
              ),
            );

            return invoice.copyWith(
              paidAmount: paid / 100,
              remainingAmount: (total - paid) / 100,
              pendingAmount: newPending / 100,
              paymentStatus: _statusAfter(
                invoice,
                paid: paid,
                pending: newPending,
              ),
            );
          },
        );

        await AppToasts.showMessage(
          field
              ? 'Collection sent to the admin for confirmation'.tr
              : 'Payment recorded successfully'.tr,
        );

        return updated;
      },
    ).checkLogicErrors();
  }

  // ==========================================================
  // REFUND PAYMENT
  // ==========================================================

  @override
  Future<InvoiceDetailModel> refundPayment(
      RefundPaymentParameters parameters) async {
    return await HandleLogicErrors<InvoiceDetailModel>(
      fun: () async {
        await Future.delayed(AppLatency.local);

        _requireAdmin();

        final updated = await _change(
          parameters.invoiceId,
          description: 'Invoice payment refunded: {0}'
              .trArgs([parameters.amount.toStringAsFixed(2)]),
          reason: parameters.reason.trim(),
          actor: parameters.actor,
          edit: (invoice, visit, ledger) {
            if (invoice.issueDate == null ||
                (invoice.paymentStatus != PaymentStatus.partiallyPaid &&
                    invoice.paymentStatus != PaymentStatus.paid)) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Invoice has no refundable payment status.'.tr,
                ),
              );
            }

            final reason = parameters.reason.trim();

            if (reason.length < 8 || reason.length > 1000) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Refund reason must be 8–1000 characters.'.tr,
                ),
              );
            }

            final cents = _cents(
              parameters.amount,
              allowZero: false,
            );

            final paid = _cents(
              invoice.paidAmount,
            );

            if (cents > paid) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Refund exceeds net paid amount.'.tr,
                ),
              );
            }

            // LOCAL DEMO LEDGER:
            // Positive entries = payments.
            // Negative entries = refunds.
            //
            // The existing InvoicePaymentHistoryModel
            // does not have a transaction status.

            final ledgerBalance =
                _ledgerSum(ledger.where((e) => e.countsAsPaid));

            if (ledgerBalance <= 0 || cents > ledgerBalance) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage:
                      'Payment history does not support this refund. Only locally recorded, unrefunded payments can be refunded.'.tr,
                ),
              );
            }

            ledger.add(
              InvoicePaymentHistoryModel(
                id: _uniqueId('refund'),
                invoiceId: parameters.invoiceId,
                paymentDate: DateTime.now(),
                paymentAmount: -cents / 100,
                paymentMethod: PaymentMethod.other,
                collectedBy: parameters.actor ?? _demoActor,
                referenceNumber: null,
                notes: 'REFUND: $reason',
              ),
            );

            final newPaid = paid - cents;
            final total = _cents(
              invoice.totalAmount,
            );

            return invoice.copyWith(
              paidAmount: newPaid / 100,
              remainingAmount: (total - newPaid) / 100,
              paymentStatus: _paymentStatus(
                newPaid,
                total,
                hadRefund: true,
              ),
            );
          },
        );

        await AppToasts.showMessage(
          'Refund recorded successfully'.tr,
        );

        return updated;
      },
    ).checkLogicErrors();
  }

  // ==========================================================
  // REVIEW A FIELD COLLECTION
  // ==========================================================

  @override
  Future<InvoiceDetailModel> reviewPayment(
      ReviewPaymentParameters parameters) async {
    return await HandleLogicErrors<InvoiceDetailModel>(
      fun: () async {
        await Future.delayed(AppLatency.local);
        _requireAdmin();

        final note = (parameters.note ?? '').trim();

        if (!parameters.approve && note.length < VisitRules.minReasonLength) {
          _fail('Please give a reason of at least {0} characters.'
              .trArgs([VisitRules.minReasonLength]));
        }

        if (note.length > 1000) {
          _fail('Notes cannot exceed 1000 characters.'.tr);
        }

        var amount = '';

        final updated = await _change(
          parameters.invoiceId,
          description: '',
          reason: note.isEmpty ? null : note,
          describe: () => parameters.approve
              ? 'Field collection of {0} confirmed'.trArgs([amount])
              : 'Field collection of {0} rejected'.trArgs([amount]),
          edit: (invoice, visit, ledger) {
            final index =
                ledger.indexWhere((e) => e.id == parameters.paymentId);

            if (index == -1) {
              _fail('Payment entry not found.'.tr);
            }

            final entry = ledger[index];

            if (!entry.isPending) {
              _fail('This collection was already reviewed.'.tr);
            }

            final cents = _cents(entry.paymentAmount, allowZero: false);
            amount = (cents / 100).toStringAsFixed(2);

            ledger[index] = entry.copyWith(
              status: parameters.approve
                  ? PaymentEntryStatus.confirmed
                  : PaymentEntryStatus.rejected,
              reviewedBy: AppSession.actor,
              reviewedAt: DateTime.now(),
              reviewNote: note.isEmpty ? null : note,
            );

            final paid =
                _cents(invoice.paidAmount) + (parameters.approve ? cents : 0);
            final pending = _cents(invoice.pendingAmount ?? 0) - cents;
            final total = _cents(invoice.totalAmount);

            return invoice.copyWith(
              paidAmount: paid / 100,
              remainingAmount: (total - paid) / 100,
              pendingAmount: pending / 100,
              paymentStatus: _statusAfter(
                invoice,
                paid: paid,
                pending: pending,
                hadRefund: ledger.any((e) => (e.paymentAmount ?? 0) < 0),
              ),
            );
          },
        );

        await AppToasts.showMessage(
          parameters.approve
              ? 'Collection confirmed'.tr
              : 'Collection rejected'.tr,
        );

        return updated;
      },
    ).checkLogicErrors();
  }

  @override
  Future<List<InvoicePaymentHistoryModel>> getPayments(
      GetPaymentsParameters parameters) async {
    return await HandleLogicErrors<List<InvoicePaymentHistoryModel>>(
      fun: () async {
        await Future.delayed(AppLatency.local);

        // A technician sees only the money they collected.
        final technicianId = AppSession.technicianId;

        final payments = _readPayments(LocalPref.sharedPreferences)
            .where((e) =>
                (parameters.invoiceId == null ||
                    e.invoiceId == parameters.invoiceId) &&
                (!parameters.pendingOnly || e.isPending) &&
                (technicianId == null || e.collectedBy?.id == technicianId))
            .toList();

        payments.sort((a, b) {
          final aDate = a.paymentDate ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.paymentDate ?? DateTime.fromMillisecondsSinceEpoch(0);

          return bDate.compareTo(aDate);
        });

        return payments;
      },
    ).checkLogicErrors();
  }

  @override
  Future<List<InvoiceDetailModel>> getInvoices(NoParameters parameters) async {
    return await HandleLogicErrors<List<InvoiceDetailModel>>(
      fun: () async {
        _requireAdmin();
        await Future.delayed(AppLatency.local);

        final list =
            LocalPref.sharedPreferences.getStringList('invoices') ?? [];

        final invoices = list
            .map(
              (e) => InvoiceDetailModel.fromJson(
                Map<String, dynamic>.from(jsonDecode(e) as Map),
              ),
            )
            .toList();

        invoices.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

          return bDate.compareTo(aDate);
        });

        return invoices;
      },
    ).checkLogicErrors();
  }
}





/*

@override
Future<List<InvoiceDetailModel>> getInvoices(
    NoParameters parameters) async {
  return await HandleLogicErrors<List<InvoiceDetailModel>>(
    fun: () async {
      await Future.delayed(AppLatency.local);

      final list =
          LocalPref.sharedPreferences.getStringList('invoices') ?? [];

      final invoices = list
          .map(
            (e) => InvoiceDetailModel.fromJson(
              Map<String, dynamic>.from(jsonDecode(e) as Map),
            ),
          )
          .toList();

      invoices.sort((a, b) {
        final aDate =
            a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        return bDate.compareTo(aDate);
      });

      return invoices;
    },
  ).checkLogicErrors();
}
*/