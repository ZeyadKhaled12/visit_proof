import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/configs/app_fonts.dart';
import 'package:visit_proof/core/utils/enums/payment_method_enum.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_drop_down.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_text_field.dart';
import 'invoice_action_policy.dart';
import 'invoice_display_widgets.dart';

/// Builds a validated command, but never sends an API request or changes models.
/// Parent receives the command to inspect/integrate separately.
class InvoiceActionSheet extends StatefulWidget {
  const InvoiceActionSheet({
    super.key,
    required this.action,
    required this.snapshot,
    required this.onPrepared,
    this.initialPayment,
  });
  final InvoiceAction action;
  final InvoiceAdminContext snapshot;
  final InvoicePaymentEntry? initialPayment;
  final ValueChanged<InvoiceActionCommand> onPrepared;

  @override
  State<InvoiceActionSheet> createState() => _InvoiceActionSheetState();
}

class _InvoiceActionSheetState extends State<InvoiceActionSheet> {
  late final TextEditingController _subtotal;
  late final TextEditingController _discount;
  late final TextEditingController _tax;
  late final TextEditingController _amount;
  late final TextEditingController _reason;
  late final TextEditingController _reference;
  late final TextEditingController _notes;
  late final TextEditingController _dateText;
  PaymentMethod? _method;
  InvoiceAdjustmentKind _kind = InvoiceAdjustmentKind.credit;
  InvoicePaymentEntry? _payment;
  DateTime? _date;
  bool _verified = false;
  String? _error;

  InvoiceAdminPolicy get rules => InvoiceAdminPolicy(widget.snapshot);

  @override
  void initState() {
    super.initState();
    final invoice = widget.snapshot.invoice;
    _subtotal = TextEditingController(text: (invoice?.subtotal ?? widget.snapshot.visit.price ?? 0).toStringAsFixed(2));
    _discount = TextEditingController(text: (invoice?.discountAmount ?? 0).toStringAsFixed(2));
    _tax = TextEditingController(text: (invoice?.taxAmount ?? 0).toStringAsFixed(2));
    _amount = TextEditingController();
    _reason = TextEditingController();
    _reference = TextEditingController();
    _notes = TextEditingController();
    _date = widget.action == InvoiceAction.changeDueDate
        ? invoice?.dueDate : DateTime.now();
    _dateText = TextEditingController(text: invoiceDate(_date));
    _payment = widget.initialPayment;
    if (_payment == null) {
      for (final item in widget.snapshot.payments) {
        if (rules.checkPayment(widget.action, item).allowed) {
          _payment = item;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    for (final c in [_subtotal, _discount, _tax, _amount, _reason,
      _reference, _notes, _dateText]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 15),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.surfaceWhite,
            surface: AppColors.surfaceWhite,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (value == null || !mounted) return;
    setState(() {
      _date = value;
      _dateText.text = invoiceDate(value);
      _error = null;
    });
  }

  Widget _field(String label, TextEditingController c, {bool numeric = false,
    int lines = 1, String? hint}) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GWidgetTextField(
        controller: c,
        labelText: label,
        hintText: hint,
        keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
        maxLines: lines,
        onChanged: (_) => setState(() => _error = null),
      ),
    );

  Widget _dateField() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: GWidgetTextField(
      labelText: widget.action == InvoiceAction.recordPayment
        ? 'Payment date' : 'Due date',
      controller: _dateText,
      readOnly: true,
      onTap: _pickDate,
      suffixIcon: IconButton(
        onPressed: _pickDate,
        icon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
      ),
    ),
  );

  List<InvoicePaymentEntry> get _eligiblePayments => widget.snapshot.payments
      .where((e) => rules.checkPayment(widget.action, e).allowed)
      .toList();

  Widget _paymentPicker() {
    final available = _eligiblePayments;
    if (available.isEmpty) return const InvoiceAlertStrip(
        message: 'No eligible payment is currently available.');
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: GWidgetDropDown<String>(
        value: _payment?.id,
        labelText: 'Select transaction',
        items: available.map((entry) => DropdownMenuItem<String>(
          value: entry.id,
          child: Text('${invoiceMoney(entry.amount, widget.snapshot.invoice?.currency)} · ${entry.payment.referenceNumber ?? entry.id}',
            overflow: TextOverflow.ellipsis,
            style: AppFonts(color: AppColors.textPrimary, fontSize: 13)),
        )).toList(),
        onChanged: (value) => setState(() {
          _payment = available.firstWhere((e) => e.id == value);
          _error = null;
        }),
      ),
    );
  }

  Widget _methodPicker() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: GWidgetDropDown<PaymentMethod>(
      value: _method,
      labelText: 'Payment method',
      hintText: 'Select a payment method',
      items: PaymentMethod.values.map((e) => DropdownMenuItem<PaymentMethod>(
        value: e,
        child: Text(PaymentMethodSwitch(paymentMethodEnum: e).getText(),
          style: AppFonts(color: AppColors.textPrimary, fontSize: 14)),
      )).toList(),
      onChanged: (v) => setState(() { _method = v; _error = null; }),
    ),
  );

  Widget _adjustmentPicker() => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: GWidgetDropDown<InvoiceAdjustmentKind>(
      value: _kind,
      labelText: 'Adjustment type',
      items: [
        DropdownMenuItem(value: InvoiceAdjustmentKind.credit,
          child: Text('Credit — decrease amount',
            style: AppFonts(color: AppColors.textPrimary))),
        DropdownMenuItem(value: InvoiceAdjustmentKind.debit,
          child: Text('Debit — increase amount',
            style: AppFonts(color: AppColors.textPrimary))),
      ],
      onChanged: (v) => setState(() {
        _kind = v ?? InvoiceAdjustmentKind.credit;
        _error = null;
      }),
    ),
  );

  Widget _formContent() {
    switch (widget.action) {
      case InvoiceAction.editAmounts:
        return Column(children: [
          const InvoiceAlertStrip(message:
              'Pricing changes on the Visit must be synchronized with this draft invoice. No issued document can be edited.'),
          const SizedBox(height: 13),
          _field('Service subtotal', _subtotal, numeric: true),
          _field('Discount amount', _discount, numeric: true),
          _field('Tax amount', _tax, numeric: true),
          Builder(builder: (_) {
            final s = InvoiceAdminPolicy.toMinorUnits(_subtotal.text);
            final d = InvoiceAdminPolicy.toMinorUnits(_discount.text);
            final t = InvoiceAdminPolicy.toMinorUnits(_tax.text);
            return InvoiceInfoRow(label: 'New total',
              value: (s != null && d != null && t != null)
                  ? invoiceMoney((s - d + t) / 100,
                      widget.snapshot.invoice?.currency)
                  : 'Invalid amounts', emphasize: true);
          }),
          _field('Reason for changing amounts', _reason, lines: 2),
        ]);
      case InvoiceAction.changeDueDate:
        return Column(children: [
          _dateField(),
          if (widget.snapshot.documentState == InvoiceDocumentState.issued)
            _field('Reason for due-date change', _reason, lines: 2),
        ]);
      case InvoiceAction.recordPayment:
        return Column(children: [
          InvoiceInfoRow(label: 'Available to collect',
              value: invoiceMoney(rules.freeToCollect, widget.snapshot.invoice?.currency),
              emphasize: true),
          const SizedBox(height: 11),
          _field('Payment amount', _amount, numeric: true),
          _methodPicker(),
          _dateField(),
          if (_method != null && _method != PaymentMethod.cash)
            _field('Transaction reference (required)', _reference),
          _field('Optional collection notes', _notes, lines: 2),
          const InvoiceAlertStrip(message:
              'The recorded payment will be Pending until explicitly confirmed. Pending amounts reserve the available balance.'),
        ]);
      case InvoiceAction.confirmPayment:
        return Column(children: [
          _paymentPicker(),
          CheckboxListTile(
            value: _verified,
            onChanged: (v) => setState(() => _verified = v ?? false),
            activeColor: AppColors.statGreen,
            title: Text('I have verified receipt of this payment',
              style: AppFonts(color: AppColors.textPrimary, fontSize: 13)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          _field('Verification note (optional)', _notes, lines: 2),
        ]);
      case InvoiceAction.reversePayment:
        return Column(children: [
          _paymentPicker(),
          const InvoiceAlertStrip(color: AppColors.statOrange,
              message: 'Reversal corrects an invalid payment record. Do not use it to send money back to a customer; use Refund.'),
          const SizedBox(height: 12),
          _field('Reversal reason (required)', _reason, lines: 2),
        ]);
      case InvoiceAction.refundPayment:
        return Column(children: [
          _paymentPicker(),
          InvoiceInfoRow(label: 'Refundable from selected payment',
            value: invoiceMoney(_payment?.refundable,
                widget.snapshot.invoice?.currency)),
          _field('Refund amount', _amount, numeric: true),
          _field('Refund / bank reference', _reference),
          _field('Refund reason (required)', _reason, lines: 2),
        ]);
      case InvoiceAction.adjustBalance:
        return Column(children: [
          const InvoiceAlertStrip(message:
              'The issued invoice is never overwritten. Create a separate credit/debit adjustment with an audit trail.'),
          const SizedBox(height: 12),
          _adjustmentPicker(),
          _field('Adjustment amount', _amount, numeric: true),
          _field('Adjustment reason (required)', _reason, lines: 2),
        ]);
      case InvoiceAction.cancelInvoice:
        return Column(children: [
          const InvoiceAlertStrip(color: AppColors.statOrange,
            message: 'Cancellation requires no confirmed or pending net payments. Financial records will remain available.'),
          const SizedBox(height: 13),
          _field('Cancellation reason (required)', _reason, lines: 2),
        ]);
      case InvoiceAction.addNote:
        return _field('Add an append-only administrative note', _reason, lines: 4);
      case InvoiceAction.create:
        return const InvoiceAlertStrip(message:
            'This will create one Draft invoice and connect it to the current Visit. Existing visits cannot receive a second invoice.');
      case InvoiceAction.issue:
        return Column(children: [
          InvoiceInfoRow(label: 'Invoice total',
            value: invoiceMoney(widget.snapshot.invoice?.totalAmount,
                widget.snapshot.invoice?.currency), emphasize: true),
          InvoiceInfoRow(label: 'Visit status', value: visitStatusLabel(widget.snapshot.visit.status)),
          InvoiceInfoRow(label: 'Due date', value: invoiceDate(widget.snapshot.invoice?.dueDate)),
          const SizedBox(height: 12),
          const InvoiceAlertStrip(message:
              'Issue locks the original invoice amounts. All later changes must be credit/debit adjustments.'),
        ]);
      case InvoiceAction.downloadPdf:
      case InvoiceAction.sendEmail:
      case InvoiceAction.sendWhatsApp:
        return InvoiceAlertStrip(message: widget.action == InvoiceAction.downloadPdf
            ? 'Only an issued invoice can be exported as a PDF.'
            : widget.action == InvoiceAction.sendEmail
                ? 'Send the issued invoice to ${widget.snapshot.invoice?.client?.email ?? ''}.'
                : 'Send the issued invoice to ${widget.snapshot.invoice?.client?.phone ?? ''}.'),
      case InvoiceAction.viewPaymentHistory:
        return const SizedBox.shrink();
    }
  }

  void _submit() {
    final action = widget.action;
    final policy = rules;
    InvoiceDecision check;
    switch (action) {
      case InvoiceAction.editAmounts:
        check = policy.validateMoneyEdit(subtotal: _subtotal.text,
          discount: _discount.text, tax: _tax.text, reason: _reason.text);
        break;
      case InvoiceAction.changeDueDate:
        check = policy.validateDueDate(_date, _reason.text);
        break;
      case InvoiceAction.recordPayment:
        check = policy.validatePayment(amount: _amount.text,
          method: _method, date: _date, reference: _reference.text);
        break;
      case InvoiceAction.refundPayment:
        check = _payment == null
          ? const InvoiceDecision.deny('اختر الدفعة المراد ردها')
          : policy.validateRefund(_payment!, _amount.text, _reason.text);
        if (check.allowed && _payment?.payment.paymentMethod != PaymentMethod.cash &&
            _reference.text.trim().isEmpty) {
          check = const InvoiceDecision.deny('مرجع تنفيذ الاسترداد مطلوب');
        }
        break;
      case InvoiceAction.adjustBalance:
        check = policy.validateAdjustment(_kind, _amount.text, _reason.text);
        break;
      case InvoiceAction.confirmPayment:
      case InvoiceAction.reversePayment:
        check = _payment == null
          ? const InvoiceDecision.deny('اختر الدفعة')
          : policy.validateReasonAction(action, _reason.text,
              payment: _payment, verified: _verified);
        break;
      default:
        check = policy.validateReasonAction(action, _reason.text);
    }
    if (!check.allowed) {
      setState(() => _error = check.reason);
      return;
    }

    final inv = widget.snapshot.invoice;
    final admin = widget.snapshot.admin;
    final data = <String, dynamic>{};
    switch (action) {
      case InvoiceAction.create:
        data.addAll({
          'visitId': widget.snapshot.visit.id,
          'initialSubtotal': widget.snapshot.visit.price,
          'clientId': widget.snapshot.visit.client?.id,
          'currency': inv?.currency,
          'newInvoiceState': 'draft',
        });
        // TODO API: Create exactly one invoice per visit (idempotency key = visitId).
        // Persist InvoiceDetailModel; set VisitDetailModel.invoiceID to new invoice.id.
        break;
      case InvoiceAction.editAmounts:
        final subtotal = InvoiceAdminPolicy.toMinorUnits(_subtotal.text)!;
        final discount = InvoiceAdminPolicy.toMinorUnits(_discount.text)!;
        final tax = InvoiceAdminPolicy.toMinorUnits(_tax.text)!;
        data.addAll({'subtotal': subtotal / 100,
          'discountAmount': discount / 100, 'taxAmount': tax / 100,
          'totalAmountPreview': (subtotal - discount + tax) / 100,
          'reason': _reason.text.trim(),
          'synchronizeVisitPrice': subtotal / 100 != widget.snapshot.visit.price});
        // TODO API: Save pricing on Draft invoice. Backend recomputes total and
        // remaining (never trusts the preview total), and updates Visit.price if
        // the base service price changed. Append history with old/new amounts.
        break;
      case InvoiceAction.issue:
        data.addAll({'issueDate': DateTime.now().toUtc().toIso8601String(),
          'dueDate': inv?.dueDate?.toIso8601String(), 'newInvoiceState': 'issued',
          'approvalForEarlyIssue': widget.snapshot.earlyIssueApproved});
        // TODO API: Atomically issue invoice after revalidating visit status,
        // totals, dueDate, permission, and unique immutable invoice number.
        break;
      case InvoiceAction.changeDueDate:
        data.addAll({'dueDate': _date!.toIso8601String(),
          'reason': _reason.text.trim(),
          'pastDueOverride': widget.snapshot.pastDueDateApproved});
        // TODO API: Patch dueDate only, retain original issuedAt and audit reason.
        break;
      case InvoiceAction.recordPayment:
        data.addAll({'paymentAmount': InvoiceAdminPolicy.toMinorUnits(_amount.text)! / 100,
          'paymentMethod': PaymentMethodSwitch(paymentMethodEnum: _method).switchID(),
          'paymentDate': _date!.toIso8601String(),
          'referenceNumber': _reference.text.trim(),
          'collectedBy': admin.toJson(), 'notes': _notes.text.trim(),
          'initialTransactionStatus': 'pending'});
        // TODO API: Create InvoicePaymentHistoryModel linked to invoiceId,
        // with Pending transaction status + idempotency key. Reserve remaining
        // balance. Do not mark paid until confirmed. Never mutate visit status.
        break;
      case InvoiceAction.confirmPayment:
        data.addAll({'paymentId': _payment!.id, 'verified': true,
          'verifiedBy': admin.id, 'verificationNotes': _notes.text.trim(),
          'newTransactionStatus': 'confirmed'});
        // TODO API: Confirm only Pending payment; recalculate paidAmount,
        // remainingAmount, invoice.paymentStatus and Visit.paymentStatus.
        break;
      case InvoiceAction.reversePayment:
        data.addAll({'paymentId': _payment!.id,
          'reason': _reason.text.trim(), 'newTransactionStatus': 'reversed'});
        // TODO API: Append reversal transaction; never delete original payment.
        // Recompute totals + Visit.paymentStatus atomically; require audit reason.
        break;
      case InvoiceAction.refundPayment:
        data.addAll({'paymentId': _payment!.id,
          'refundAmount': InvoiceAdminPolicy.toMinorUnits(_amount.text)! / 100,
          'referenceNumber': _reference.text.trim(),
          'reason': _reason.text.trim()});
        // TODO API: Create refund record linked to the confirmed payment;
        // update refundedAmount and net paid amounts. Keep original payment.
        // Recalculate invoice and visit payment status, including partial refund.
        break;
      case InvoiceAction.adjustBalance:
        data.addAll({'type': _kind.name,
          'amount': InvoiceAdminPolicy.toMinorUnits(_amount.text)! / 100,
          'reason': _reason.text.trim(), 'sourceInvoiceId': inv?.id});
        // TODO API: Post separate signed credit/debit adjustment/credit note.
        // Never overwrite issued document or its original totals. Update
        // outstanding adjusted balance, and both Invoice/Visit paymentStatus
        // where applicable, with payment/refund reconciliation.
        break;
      case InvoiceAction.cancelInvoice:
        data.addAll({'reason': _reason.text.trim(),
          'newInvoiceState': 'cancelled',
          'independentCancellationApproved': widget.snapshot.independentCancellationApproved});
        // TODO API: Cancel document only after clearing pending/paid balances
        // and handling cancellation fees. Preserve original immutable invoice;
        // update Visit.paymentStatus if the outstanding obligation is cancelled.
        break;
      case InvoiceAction.addNote:
        data.addAll({'note': _reason.text.trim(), 'createdBy': admin.id});
        // TODO API: Append an InvoiceActivityEntry; do NOT overwrite old notes.
        break;
      case InvoiceAction.downloadPdf:
        data.addAll({'format': 'pdf', 'invoiceId': inv?.id});
        // TODO API: Request/download generated PDF for ISSUED invoice only.
        break;
      case InvoiceAction.sendEmail:
        data.addAll({'channel': 'email', 'recipient': inv?.client?.email});
        // TODO API: Email issued PDF and append delivery attempt history.
        break;
      case InvoiceAction.sendWhatsApp:
        data.addAll({'channel': 'whatsapp', 'recipient': inv?.client?.phone});
        // TODO API: Share PDF via authorized WhatsApp integration; log result.
        break;
      case InvoiceAction.viewPaymentHistory:
        return; // Navigates to local history screen; no mutation.
    }

    widget.onPrepared(InvoiceActionCommand(
      action: action,
      visitId: widget.snapshot.visit.id!,
      invoiceId: inv?.id,
      actorId: admin.id!,
      data: data,
    ));
    // IMPORTANT: Closing this form does NOT mean data was saved. The parent
    // must wire the API and reload both visit/invoice/payment ledger on success.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final danger = action == InvoiceAction.cancelInvoice ||
        action == InvoiceAction.refundPayment ||
        action == InvoiceAction.reversePayment;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .88),
          decoration: const BoxDecoration(color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
            child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Center(child: Container(width: 42, height: 4,
                decoration: BoxDecoration(color: AppColors.iconLightGrey,
                  borderRadius: BorderRadius.circular(3)))),
              const SizedBox(height: 20),
              Row(children: [
                Container(padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: invoiceActionColor(action).withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(15)),
                  child: Icon(invoiceActionIcon(action),
                    color: invoiceActionColor(action), size: 25)),
                const SizedBox(width: 12),
                Expanded(child: Text(invoiceActionTitle(action),
                  style: AppFonts(fontSize: 19, color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800))),
                IconButton(onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.iconGrey)),
              ]),
              const SizedBox(height: 20),
              _formContent(),
              if (_error != null) ...[
                const SizedBox(height: 8),
                InvoiceAlertStrip(message: _error!, color: AppColors.statOrange,
                  icon: Icons.error_outline_rounded),
              ],
              const SizedBox(height: 22),
              GWidgetButton(
                text: danger ? 'Confirm action' : 'Continue',
                colorText: AppColors.surfaceWhite,
                backgroundColor: danger ? AppColors.statOrange : AppColors.primary,
                onPressed: _submit,
                height: 52, fontSize: 15, raduis: 15,
              ),
              const SizedBox(height: 8),
              Text('Rules checked before command preparation. No API call is performed.',
                textAlign: TextAlign.center,
                style: AppFonts(fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ),
        ),
      ),
    );
  }
}
