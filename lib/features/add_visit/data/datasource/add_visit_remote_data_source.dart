import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';

import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/core/local/local_pref.dart';
import 'package:visit_proof/core/utils/general_functions.dart/g_fun_token.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';

import 'package:visit_proof/core/network/error/handle_logic_errors.dart';

// Adjust these two imports to your existing project paths.
import 'package:visit_proof/core/network/error/error_message_model.dart';

import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';

import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_history_model.dart';

import '../../../../core/network/error/exception.dart';
import '../../domain/usecases/add_visit_uc.dart';


abstract class BaseAddVisitRemoteDataSource {
  Future<VisitDetailModel> addVisit(AddVisitParameters parameters);
}

class AddVisitRemoteDataSource extends BaseAddVisitRemoteDataSource {
  static const String _visitsKey = 'visits';
  static const String _invoicesKey = 'invoices';

  // Prevent simultaneous addVisit calls from generating
  // duplicate sequential numbers in the same Dart isolate.
  static Future<void> _writeQueue = Future<void>.value();

  Future<T> _exclusive<T>(
    Future<T> Function() action,
  ) async {
    final previous = _writeQueue;
    final completer = Completer<void>();

    _writeQueue = completer.future;
    await previous;

    try {
      return await action();
    } finally {
      completer.complete();
    }
  }

  void _error(String message) {
    throw ServerException(
      ErrorMessageModel(
        statusMessage: message,
      ),
    );
  }


  String _nextNumber(
    List<String?> numbers,
    String prefix,
  ) {
    int maxNumber = 0;

    for (final number in numbers) {
      if (number == null) continue;

      final match = RegExp(
        '^${RegExp.escape(prefix)}-(\\d+)\$',
      ).firstMatch(number);

      if (match == null) continue;

      final current = int.tryParse(match.group(1) ?? '') ?? 0;

      if (current > maxNumber) {
        maxNumber = current;
      }
    }

    return '$prefix-${(maxNumber + 1).toString().padLeft(6, '0')}';
  }

  @override
  Future<VisitDetailModel> addVisit(
    AddVisitParameters parameters,
  ) async {
    return await HandleLogicErrors<VisitDetailModel>(
      fun: () async {
        await Future.delayed(
          const Duration(seconds: 1),
        );

        return await _exclusive(() async {
          final preferences = LocalPref.sharedPreferences;

          final DateTime now = DateTime.now();

          // ==================================================
          // 1. READ EXISTING VISITS
          // ==================================================

          final oldVisits = preferences.getStringList(_visitsKey);

          final List<VisitDetailModel> visits = (oldVisits ?? <String>[])
              .map(
                (e) => VisitDetailModel.fromJson(
                  Map<String, dynamic>.from(
                    jsonDecode(e) as Map,
                  ),
                ),
              )
              .toList();

          // ==================================================
          // 2. READ EXISTING INVOICES
          // ==================================================

          final oldInvoices = preferences.getStringList(_invoicesKey);

          final List<InvoiceDetailModel> invoices = (oldInvoices ?? <String>[])
              .map(
                (e) => InvoiceDetailModel.fromJson(
                  Map<String, dynamic>.from(
                    jsonDecode(e) as Map,
                  ),
                ),
              )
              .toList();

          // ==================================================
          // 3. VALIDATE NEW VISIT
          // ==================================================

          VisitDetailModel visit = parameters.visitDetailModel;

          // If no status is provided, use Draft.
          final VisitStatus status = visit.status ?? VisitStatus.draft;

          if (status != VisitStatus.draft &&
              status != VisitStatus.scheduled &&
              status != VisitStatus.assigned) {
            _error(
              'A new visit can only be Draft, '
              'Scheduled, or Assigned.',
            );
          }

          // This function creates new visits only.
          if ((visit.id ?? '').trim().isNotEmpty) {
            _error(
              'The new visit must not already have an ID.',
            );
          }

          if ((visit.invoiceID ?? '').trim().isNotEmpty) {
            _error(
              'A new visit cannot already have an invoice.',
            );
          }

          // Scheduled and Assigned require complete data.
          if (status == VisitStatus.scheduled ||
              status == VisitStatus.assigned) {
            if (visit.client?.id == null ||
                (visit.client?.id ?? '').trim().isEmpty) {
              _error(
                'Please select a client before scheduling '
                'or assigning the visit.',
              );
            }

            if (visit.site == null) {
              _error(
                'Visit location is required.',
              );
            }

            if ((visit.serviceName ?? '').trim().isEmpty) {
              _error(
                'Please select a service.',
              );
            }

            if (visit.startDate == null) {
              _error(
                'Visit start date is required.',
              );
            }

            if (visit.durationInMin == null || visit.durationInMin! <= 0) {
              _error(
                'Visit duration must be greater than zero.',
              );
            }

            if (visit.price == null) {
              _error(
                'Visit price is required.',
              );
            }
          }

          // Assigned must have a technician.
          if (status == VisitStatus.assigned && visit.technicianModel == null) {
            _error(
              'Please assign a technician before creating '
              'an Assigned visit.',
            );
          }

          // Scheduling a technician is an Assigned visit.
          if (status == VisitStatus.scheduled &&
              visit.technicianModel != null) {
            _error(
              'A visit with an assigned technician '
              'must use Assigned status.',
            );
          }

          // Draft visits should not already have a technician.
          if (status == VisitStatus.draft && visit.technicianModel != null) {
            _error(
              'Remove the technician or create '
              'the visit as Assigned.',
            );
          }

          // Validate price even for Draft when provided.
          final double price = (visit.price ?? 0).toDouble();

          if (!price.isFinite || price < 0) {
            _error(
              'Visit price must be a valid non-negative amount.',
            );
          }

          final double priceInCents = price * 100;

          if (!priceInCents.isFinite ||
              priceInCents > 9000000000000000 ||
              (priceInCents - priceInCents.round()).abs() > 0.000001) {
            _error(
              'Visit price must have at most 2 decimal places.',
            );
          }

          final num invoiceTotal = priceInCents.round() / 100;

          // ==================================================
          // 4. GENERATE VISIT AND INVOICE IDs
          // ==================================================

          String visitID = GFunToken.generateRandomId();
          String invoiceID = GFunToken.generateRandomId();

          // Avoid collisions with locally stored records.
          while (visits.any((v) => v.id == visitID) ||
              invoices.any((i) => i.visitId == visitID)) {
            visitID = GFunToken.generateRandomId();
          }

          while (
              invoices.any((i) => i.id == invoiceID) || invoiceID == visitID) {
            invoiceID = GFunToken.generateRandomId();
          }

          final String visitNumber = _nextNumber(
            visits.map((e) => e.visitNumber).toList(),
            'VIS',
          );

          final String invoiceNumber = _nextNumber(
            invoices.map((e) => e.invoiceNumber).toList(),
            'INV',
          );

          // ==================================================
          // 5. CREATE VISIT HISTORY
          // ==================================================

          final VisitHistoryActorModel admin = VisitHistoryActorModel(
            id: GFunToken.generateRandomId(),
            role: 'Admin',
          );

          final List<VisitHistoryModel> history = [
            VisitHistoryModel(
              id: GFunToken.generateRandomId(),
              visitId: visitID,
              recordedAt: now,
              actor: admin,
              description: 'Admin created this visit at '
                  '${DateFormat('dd MMM yyyy').format(now)}',
            ),
          ];

          if (status == VisitStatus.scheduled ||
              status == VisitStatus.assigned) {
            history.add(
              VisitHistoryModel(
                id: GFunToken.generateRandomId(),
                visitId: visitID,
                recordedAt: now,
                actor: admin,
                description: 'Admin created this visit with status '
                    '${VisitStatusSwitch(visitStatusEnum: status).getText()} '
                    'at ${DateFormat('dd MMM yyyy').format(now)}',
              ),
            );
          }

          // ==================================================
          // 6. CREATE VISIT AND ATTACH INVOICE
          // ==================================================

          visit = visit.copyWith(
            id: visitID,
            visitNumber: visitNumber,
            status: status,
            invoiceID: invoiceID,
            paymentStatus: PaymentStatus.unpaid,
            history: history,
          );

          // ==================================================
          // 7. CREATE INVOICE MODEL
          // ==================================================

          final InvoiceDetailModel invoice = InvoiceDetailModel(
            id: invoiceID,
            invoiceNumber: invoiceNumber,

            // One-to-one visit relationship.
            visitId: visitID,
            visitNumber: visitNumber,

            // Snapshot of client and location.
            client: visit.client,
            site: visit.site,

            // New invoices always start unpaid.
            paymentStatus: PaymentStatus.unpaid,

            createdAt: now,

            // The invoice has not been issued yet.
            issueDate: null,
            dueDate: null,

            // Financial details.
            subtotal: invoiceTotal,
            discountAmount: 0,
            taxAmount: 0,
            totalAmount: invoiceTotal,
            paidAmount: 0,
            remainingAmount: invoiceTotal,

            currency: 'EGP',
            notes: null,
          );

          // ==================================================
          // 8. CHECK ONE INVOICE PER VISIT
          // ==================================================

          if (invoices.any(
            (element) =>
                element.visitId == visit.id || element.id == invoice.id,
          )) {
            _error(
              'This visit already has an invoice.',
            );
          }

          if (visits.any(
            (element) =>
                element.id == visit.id ||
                element.visitNumber == visit.visitNumber ||
                (element.invoiceID != null && element.invoiceID == invoice.id),
          )) {
            _error(
              'Duplicate visit or invoice relationship.',
            );
          }

          // ==================================================
          // 9. ADD BOTH MODELS TO LOCAL LISTS
          // ==================================================

          visits.insert(0, visit);
          invoices.insert(0, invoice);

          // Prepare serialized data BEFORE any writes.
          final List<String> visitsJson =
              visits.map((e) => jsonEncode(e.toJson())).toList();

          final List<String> invoicesJson =
              invoices.map((e) => jsonEncode(e.toJson())).toList();

          // ==================================================
          // 10. SAVE VISIT AND INVOICE
          // ==================================================

          // SharedPreferences does not support transactions
          // across multiple keys.
          //
          // We write the invoice first, then the visit.
          // If a write fails normally, attempt rollback.
          // This is best-effort, not crash-safe.

          try {
            final bool invoiceSaved = await preferences.setStringList(
              _invoicesKey,
              invoicesJson,
            );

            if (!invoiceSaved) {
              _error(
                'Failed to save invoice locally.',
              );
            }

            final bool visitSaved = await preferences.setStringList(
              _visitsKey,
              visitsJson,
            );

            if (!visitSaved) {
              _error(
                'Failed to save visit locally.',
              );
            }
          } catch (e) {
            // Restore previous invoice data.
            try {
              if (oldInvoices == null) {
                await preferences.remove(_invoicesKey);
              } else {
                await preferences.setStringList(
                  _invoicesKey,
                  oldInvoices,
                );
              }

              // Restore previous visit data.
              if (oldVisits == null) {
                await preferences.remove(_visitsKey);
              } else {
                await preferences.setStringList(
                  _visitsKey,
                  oldVisits,
                );
              }
            } catch (_) {
              // Rollback is best-effort only.
              // Local recovery may be required.
            }

            rethrow;
          }

          // ==================================================
          // 11. SUCCESS
          // ==================================================

          await AppToasts.showMessage(
            'Visit and invoice added successfully',
          );

          // Return VisitDetailModel with the linked invoiceID.
          return visit;
        });
      },
    ).checkLogicErrors();
  }
}
