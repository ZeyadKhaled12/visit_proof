import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/core/local/local_pref.dart';
import 'package:visit_proof/core/network/error/handle_logic_errors.dart';
import 'package:visit_proof/core/network/error/error_message_model.dart';
import 'package:visit_proof/core/utils/general_functions.dart/g_fun_token.dart';
import 'package:visit_proof/core/utils/enums/payment_method_enum.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';

import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_payment_history_model.dart';

import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_history_model.dart';

import '../../../../core/network/error/exception.dart';

// ============================================================
// PARAMETERS
// ============================================================

class SaveInvoiceParameters {
  final InvoiceDetailModel invoice;

  const SaveInvoiceParameters({
    required this.invoice,
  });
}

class GetInvoiceDetailParameters {
  final String invoiceId;

  const GetInvoiceDetailParameters({
    required this.invoiceId,
  });
}

class IssueInvoiceParameters {
  final String invoiceId;
  final bool allowEarlyIssue;
  final String? overrideReason;

  const IssueInvoiceParameters({
    required this.invoiceId,
    this.allowEarlyIssue = false,
    this.overrideReason,
  });
}

class UpdateDraftInvoiceParameters {
  final String invoiceId;
  final num discountAmount;
  final num taxAmount;
  final String notes;
  final bool allowPriceOverride;
  final String? overrideReason;

  const UpdateDraftInvoiceParameters({
    required this.invoiceId,
    required this.discountAmount,
    required this.taxAmount,
    required this.notes,
    this.allowPriceOverride = false,
    this.overrideReason,
  });
}

class RecordInvoicePaymentParameters {
  final String invoiceId;
  final num amount;
  final PaymentMethod paymentMethod;
  final String? referenceNumber;
  final String? notes;
  final VisitHistoryActorModel? collectedBy;

  const RecordInvoicePaymentParameters({
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
    this.referenceNumber,
    this.notes,
    this.collectedBy,
  });
}

class RefundInvoicePaymentParameters {
  final String invoiceId;
  final num amount;
  final String reason;
  final VisitHistoryActorModel? actor;

  const RefundInvoicePaymentParameters({
    required this.invoiceId,
    required this.amount,
    required this.reason,
    this.actor,
  });
}

// ============================================================
// BASE DATA SOURCE
// ============================================================

abstract class BaseInvoicesRemoteDataSource {
  Future<InvoiceDetailModel> getOrCreateInvoice(
    SaveInvoiceParameters parameters,
  );

  Future<InvoiceDetailModel> getInvoiceDetail(
    GetInvoiceDetailParameters parameters,
  );

  Future<InvoiceDetailModel> issueInvoice(
    IssueInvoiceParameters parameters,
  );

  Future<InvoiceDetailModel> updateDraftInvoice(
    UpdateDraftInvoiceParameters parameters,
  );

  Future<InvoiceDetailModel> recordPayment(
    RecordInvoicePaymentParameters parameters,
  );

  Future<InvoiceDetailModel> refundPayment(
    RefundInvoicePaymentParameters parameters,
  );
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

  static final VisitHistoryActorModel _demoActor = VisitHistoryActorModel(
    id: 'local-admin',
    name: 'Local Admin',
    role: 'admin',
  );

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
            statusMessage: 'Could not save payments.',
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
            statusMessage: 'Could not save visits.',
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
            statusMessage: 'Could not save invoices.',
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
          statusMessage: 'Invoice not found or duplicated: $invoiceId',
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
          statusMessage: 'The linked visit is missing from local storage. '
              'Save the VisitDetailModel in the "visits" preference first.',
        ),
      );
    }

    final visit = matches.single;

    if (visit.invoiceID != null && visit.invoiceID != invoice.id) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'This visit is already linked to another invoice.',
        ),
      );
    }

    if (visit.status == null) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Visit status is missing.',
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
          statusMessage: 'A valid financial amount is required.',
        ),
      );
    }

    final amount = value.toDouble() * 100;

    if (!amount.isFinite || amount.abs() > 9000000000000000) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Amount is outside the supported range.',
        ),
      );
    }

    if ((amount - amount.round()).abs() > 0.000001) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Amounts must have at most 2 decimal places.',
        ),
      );
    }

    final cents = amount.round();

    if ((!allowNegative && cents < 0) || (!allowZero && cents == 0)) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Amount must be greater than zero.',
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
          statusMessage: 'Invoice and visit IDs are required.',
        ),
      );
    }

    if (invoice.paymentStatus == null) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Invoice payment status is missing.',
        ),
      );
    }

    final total = _cents(invoice.totalAmount);
    final paid = _cents(invoice.paidAmount);
    final remaining = _cents(invoice.remainingAmount);

    if (paid > total || remaining != total - paid) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Invoice totals are inconsistent.',
        ),
      );
    }

    if ((invoice.paymentStatus == PaymentStatus.unpaid && paid != 0) ||
        (invoice.paymentStatus == PaymentStatus.partiallyPaid &&
            (paid <= 0 || paid >= total)) ||
        (invoice.paymentStatus == PaymentStatus.paid && paid != total)) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Payment status does not match the paid amount.',
        ),
      );
    }

    final subtotal = _cents(invoice.subtotal);
    final discount = _cents(invoice.discountAmount);
    final tax = _cents(invoice.taxAmount);

    if (discount > subtotal || subtotal - discount + tax != total) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Subtotal, discount, tax and total do not match.',
        ),
      );
    }

    if ((invoice.currency ?? '').trim().isEmpty) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Invoice currency is required.',
        ),
      );
    }

    if ((invoice.client?.id ?? '').trim().isEmpty ||
        (invoice.client?.name ?? '').trim().isEmpty) {
      throw ServerException(
        ErrorMessageModel(
          statusMessage: 'Invoice client must be complete.',
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
          statusMessage: 'Due date cannot precede issue date.',
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
    SaveInvoiceParameters parameters,
  ) async {
    return await HandleLogicErrors<InvoiceDetailModel>(
      fun: () async {
        await Future.delayed(
          const Duration(milliseconds: 350),
        );

        return await _exclusive(() async {
          final invoice = parameters.invoice;

          if ((invoice.id ?? '').trim().isEmpty ||
              (invoice.visitId ?? '').trim().isEmpty) {
            throw ServerException(
              ErrorMessageModel(
                statusMessage: 'Invoice and visit IDs are required.',
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
                      'Cannot change the visit of an existing invoice.',
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
                statusMessage: 'Only one invoice is allowed per visit.',
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
                  notes: 'DEMO OPENING BALANCE: imported snapshot, '
                      'not a verified payment transaction.',
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
        await Future.delayed(
          const Duration(milliseconds: 350),
        );

        return await _exclusive(() async {
          if (parameters.invoiceId.trim().isEmpty) {
            throw ServerException(
              ErrorMessageModel(
                statusMessage: 'Invoice ID is required.',
              ),
            );
          }

          final invoices = _readInvoices(
            LocalPref.sharedPreferences,
          );

          return _findInvoice(
            invoices,
            parameters.invoiceId,
          );
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

      final ledgerPaid = ledger.fold<int>(
        0,
        (sum, payment) =>
            sum +
            _cents(
              payment.paymentAmount,
              allowNegative: true,
            ),
      );

      if (ledgerPaid != _cents(current.paidAmount)) {
        throw ServerException(
          ErrorMessageModel(
            statusMessage: 'Payment history and paid balance are inconsistent.',
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
            statusMessage: 'Invoice identity cannot be changed.',
          ),
        );
      }

      if (invoices.any(
        (e) => e.id != updated.id && e.visitId == updated.visitId,
      )) {
        throw ServerException(
          ErrorMessageModel(
            statusMessage: 'Only one invoice is allowed per visit.',
          ),
        );
      }

      // Append new payment entries only.
      final existingIds = payments.map((e) => e.id).toSet();

      for (final payment in ledger) {
        if (payment.id == null) {
          throw ServerException(
            ErrorMessageModel(
              statusMessage: 'Payment entry is missing its identifier.',
            ),
          );
        }

        if (!existingIds.contains(payment.id)) {
          payments.add(payment);
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
          description: description,
          reason: reason,
        ),
      );

      visits[visitIndex] = visit.copyWith(
        invoiceID: updated.id,
        paymentStatus: updated.paymentStatus,
        history: history,
      );

      await _save(
        invoices: invoices,
        visits: visits,
        payments: payments,
      );

      return updated;
    });
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
        await Future.delayed(
          const Duration(milliseconds: 350),
        );

        final updated = await _change(
          parameters.invoiceId,
          description: 'Invoice issued',
          reason: parameters.overrideReason,
          edit: (invoice, visit, ledger) {
            if (invoice.issueDate != null ||
                invoice.paymentStatus != PaymentStatus.unpaid ||
                _cents(invoice.paidAmount) != 0) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Only an unpaid draft invoice can be issued.',
                ),
              );
            }

            if (ledger.isNotEmpty) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'A draft invoice cannot have payment entries.',
                ),
              );
            }

            if (_cents(invoice.totalAmount) <= 0) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Invoice total must exceed zero.',
                ),
              );
            }

            if (visit.status == VisitStatus.cancel) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage:
                      'Cannot issue an invoice for a cancelled visit.',
                ),
              );
            }

            if (visit.status != VisitStatus.completed) {
              if (!parameters.allowEarlyIssue ||
                  (parameters.overrideReason ?? '').trim().length < 8) {
                throw ServerException(
                  ErrorMessageModel(
                    statusMessage:
                        'Complete the visit first, or provide an approved '
                        'early-issue override with a reason.',
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
                  statusMessage: 'Due date must not be before issue date.',
                ),
              );
            }

            return invoice.copyWith(
              issueDate: now,
            );
          },
        );

        await AppToasts.showMessage(
          'Invoice issued successfully',
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
        await Future.delayed(
          const Duration(milliseconds: 350),
        );

        final updated = await _change(
          parameters.invoiceId,
          description: 'Draft invoice updated',
          reason: parameters.overrideReason,
          edit: (invoice, visit, ledger) {
            if (invoice.issueDate != null ||
                invoice.paymentStatus != PaymentStatus.unpaid ||
                _cents(invoice.paidAmount) != 0 ||
                ledger.isNotEmpty) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Only an unpaid draft can be edited.',
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
                      'The visit status does not allow invoice edits.',
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
                  statusMessage: 'Discount cannot exceed the subtotal.',
                ),
              );
            }

            final total = subtotal - discount + tax;

            if (total < 0) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Invoice total cannot be negative.',
                ),
              );
            }

            if (parameters.notes.trim().length > 1000) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Notes cannot exceed 1000 characters.',
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
          'Draft invoice updated successfully',
        );

        return updated;
      },
    ).checkLogicErrors();
  }

  // ==========================================================
  // RECORD PAYMENT
  // ==========================================================

  @override
  Future<InvoiceDetailModel> recordPayment(
    RecordInvoicePaymentParameters parameters,
  ) async {
    return await HandleLogicErrors<InvoiceDetailModel>(
      fun: () async {
        await Future.delayed(
          const Duration(milliseconds: 350),
        );

        final updated = await _change(
          parameters.invoiceId,
          description: 'Invoice payment recorded: ${parameters.amount}',
          actor: parameters.collectedBy,
          edit: (invoice, visit, ledger) {
            if (invoice.issueDate == null ||
                (invoice.paymentStatus != PaymentStatus.unpaid &&
                    invoice.paymentStatus != PaymentStatus.partiallyPaid)) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage:
                      'Only an issued, collectible invoice can be paid.',
                ),
              );
            }

            if (visit.status == VisitStatus.draft ||
                visit.status == VisitStatus.cancel) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'This visit cannot accept payments.',
                ),
              );
            }

            final cents = _cents(
              parameters.amount,
              allowZero: false,
            );

            final remaining = _cents(
              invoice.remainingAmount,
            );

            if (cents > remaining) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Payment exceeds the remaining balance.',
                ),
              );
            }

            final reference = (parameters.referenceNumber ?? '').trim();

            if (parameters.paymentMethod != PaymentMethod.cash &&
                reference.isEmpty) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Transaction reference is required.',
                ),
              );
            }

            if (reference.length > 100 ||
                (parameters.notes ?? '').length > 1000) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Reference or notes are too long.',
                ),
              );
            }

            if (parameters.paymentMethod == PaymentMethod.other &&
                (parameters.notes ?? '').trim().isEmpty) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Explain the selected payment method.',
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
                      'This transaction reference was already recorded.',
                ),
              );
            }

            final paid = _cents(invoice.paidAmount) + cents;

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
                collectedBy: parameters.collectedBy ?? _demoActor,
                referenceNumber: reference.isEmpty ? null : reference,
                notes: (parameters.notes ?? '').trim(),
              ),
            );

            return invoice.copyWith(
              paidAmount: paid / 100,
              remainingAmount: (total - paid) / 100,
              paymentStatus: _paymentStatus(
                paid,
                total,
              ),
            );
          },
        );

        await AppToasts.showMessage(
          'Payment recorded successfully',
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
    RefundInvoicePaymentParameters parameters,
  ) async {
    return await HandleLogicErrors<InvoiceDetailModel>(
      fun: () async {
        await Future.delayed(
          const Duration(milliseconds: 350),
        );

        final updated = await _change(
          parameters.invoiceId,
          description: 'Invoice payment refunded: ${parameters.amount}',
          reason: parameters.reason.trim(),
          actor: parameters.actor,
          edit: (invoice, visit, ledger) {
            if (invoice.issueDate == null ||
                (invoice.paymentStatus != PaymentStatus.partiallyPaid &&
                    invoice.paymentStatus != PaymentStatus.paid)) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Invoice has no refundable payment status.',
                ),
              );
            }

            final reason = parameters.reason.trim();

            if (reason.length < 8 || reason.length > 1000) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage: 'Refund reason must be 8–1000 characters.',
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
                  statusMessage: 'Refund exceeds net paid amount.',
                ),
              );
            }

            // LOCAL DEMO LEDGER:
            // Positive entries = payments.
            // Negative entries = refunds.
            //
            // The existing InvoicePaymentHistoryModel
            // does not have a transaction status.

            var ledgerBalance = 0;

            for (final entry in ledger) {
              ledgerBalance += _cents(
                entry.paymentAmount,
                allowNegative: true,
              );
            }

            if (ledgerBalance <= 0 || cents > ledgerBalance) {
              throw ServerException(
                ErrorMessageModel(
                  statusMessage:
                      'Payment history does not support this refund. '
                      'Only locally recorded, unrefunded payments can be refunded.',
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
          'Refund recorded successfully',
        );

        return updated;
      },
    ).checkLogicErrors();
  }
}
