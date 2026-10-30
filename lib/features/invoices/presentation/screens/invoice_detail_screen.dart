import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/configs/app_fonts.dart';
import 'package:visit_proof/core/utils/enums/payment_method_enum.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_bottom_sheet.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_drop_down.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_navi_body.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_text_field.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/invoices/data/data_sources/invoices_remote_data_source.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_loading.dart';
import '../widgets/invoice_detail_parts.dart';

/// Single input: existing InvoiceDetailModel.
/// No additional business models or enums.
/// All mutations and validations run locally through SharedPreferences.
class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({
    super.key,
    required this.invoice,
  });

  final InvoiceDetailModel invoice;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final BaseInvoicesRemoteDataSource _dataSource = InvoicesRemoteDataSource();
  late InvoiceDetailModel _invoice;
  bool _loading = true;
  bool _busy = false;
  bool _storageReady = false;

  InvoiceDetailModel get i => _invoice;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
    _loadInvoice();
  }

  @override
  void didUpdateWidget(covariant InvoiceDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.invoice.id != widget.invoice.id) {
      _invoice = widget.invoice;
      _storageReady = false;
      _loadInvoice();
    }
  }

  Future<void> _loadInvoice() async {
    setState(() => _loading = true);
    try {
      // Seed only on first open; subsequent opens fetch persisted values.
      final saved = await _dataSource.getOrCreateInvoice(SaveInvoiceParameters(invoice: widget.invoice));
      if (!mounted || saved.id != widget.invoice.id) return;
      setState(() {
        _invoice = saved;
        _storageReady = true;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _storageReady = false);
        _info(_errorText(error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshInvoice() async {
    if (_busy || _loading || i.id == null) return;
    setState(() => _loading = true);
    try {
      final saved = await _dataSource.getInvoiceDetail(GetInvoiceDetailParameters(invoiceId: i.id!));
      if (mounted) setState(() {
        _invoice = saved;
        _storageReady = true;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _storageReady = false);
        _info(_errorText(error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _runAction(
    Future<InvoiceDetailModel> Function() action,
  ) async {
    if (_busy || _loading || !_storageReady) return false;
    setState(() => _busy = true);
    try {
      final updated = await action();
      if (!mounted) return false;
      setState(() => _invoice = updated);
      // Success toast is already displayed by InvoicesRemoteDataSource.
      return true;
    } catch (error) {
      if (mounted) _info(_errorText(error));
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  double get _total => i.totalAmount?.toDouble() ?? 0;
  double get _paid => i.paidAmount?.toDouble() ?? 0;
  double get _remaining => i.remainingAmount?.toDouble() ?? 0;

  bool get _hasId =>
      (i.id?.trim().isNotEmpty ?? false) &&
      (i.visitId?.trim().isNotEmpty ?? false);

  bool get _hasCompleteAmounts =>
      i.totalAmount != null &&
      i.paidAmount != null &&
      i.remainingAmount != null &&
      _total.isFinite &&
      _paid.isFinite &&
      _remaining.isFinite &&
      _total >= 0 &&
      _paid >= 0 &&
      _remaining >= 0 &&
      (_total - _paid - _remaining).abs() < 0.011;

  bool get _terminal =>
      i.paymentStatus == PaymentStatus.cancelled ||
      i.paymentStatus == PaymentStatus.refunded;

  bool get _unpaid => i.paymentStatus == PaymentStatus.unpaid;

  bool get _partial => i.paymentStatus == PaymentStatus.partiallyPaid;

  bool get _paidInFull => i.paymentStatus == PaymentStatus.paid;

  bool get _hasIssueDate => i.issueDate != null;

  // IMPORTANT:
  // issueDate is only a UI hint, NOT a replacement for InvoiceStatus.
  //
  // Existing model uses issueDate as draft / issued marker.
  // Linked VisitStatus and payment history are validated by the source.

  bool get _canIssue =>
      _storageReady &&
      _hasId &&
      !_hasIssueDate &&
      _unpaid &&
      _hasCompleteAmounts &&
      _paid == 0 &&
      _total > 0;

  bool get _canEdit =>
      _storageReady &&
      _hasId && !_hasIssueDate && _unpaid && _hasCompleteAmounts && _paid == 0;

  bool get _canRecord =>
      _storageReady &&
      _hasId &&
      _hasIssueDate &&
      !_terminal &&
      (_unpaid || _partial) &&
      _hasCompleteAmounts &&
      _remaining > 0;

  bool get _canRefund =>
      _storageReady &&
      _hasId &&
      _hasIssueDate &&
      !_terminal &&
      (_partial || _paidInFull) &&
      _hasCompleteAmounts &&
      _paid > 0;


  String _money(num? amount) =>
      '${(amount ?? 0).toStringAsFixed(2)} ${i.currency ?? ''}'.trim();

  String _date(DateTime? value) {
    if (value == null) return '—';

    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  // ------------------------------------------------------
  // Shared money validation
  // ------------------------------------------------------

  String? _requiredMoney(
    String? text, {
    required double max,
    bool allowZero = false,
  }) {
    final v = (text ?? '').trim();

    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(v)) {
      return 'Enter a valid amount (up to 2 decimals)';
    }

    final number = double.tryParse(v);

    if (number == null ||
        !number.isFinite ||
        (allowZero ? number < 0 : number <= 0)) {
      return allowZero
          ? 'Amount cannot be negative'
          : 'Amount must be above zero';
    }

    if (number > max + 0.001) {
      return 'Maximum allowed: ${_money(max)}';
    }

    return null;
  }

  void _info(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: AppFonts(
            color: AppColors.surfaceWhite,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // The source re-reads the current Visit and ledger for each mutation.
  // UI only updates _invoice after successful local storage writes.

  Future<void> _showSheet({
    required String title,
    required String subtitle,
    required Widget child,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) => GWidgetBottomSheet(
        title: title,
        subtitle: subtitle,
        body: child,
      ),
    );
  }

  // ======================================================
  // ACTION 1: ISSUE INVOICE
  // ======================================================

  Future<void> _issueInvoice() async {
    if (!_canIssue) return;

    if (i.client?.id == null ||
        i.client?.name?.trim().isEmpty != false ||
        i.currency?.trim().isEmpty != false ||
        i.subtotal == null ||
        i.discountAmount == null ||
        i.taxAmount == null) {
      _info('Complete client, currency and invoice amounts.');
      return;
    }

    if (((i.subtotal! - i.discountAmount! + i.taxAmount!) - _total).abs() >
        .011) {
      _info('Invoice breakdown does not match the total.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceWhite,
        title: Text(
          'Issue invoice?',
          style: AppFonts(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Total: ${_money(_total)}\n'
          'Check the linked visit before confirming.',
          style: AppFonts(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Back',
              style: AppFonts(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Continue',
              style: AppFonts(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await _runAction(
      () => _dataSource.issueInvoice(IssueInvoiceParameters(invoiceId: i.id!)),
    );
  }

  // ======================================================
  // ACTION 2: RECORD PAYMENT
  // ======================================================

  Future<void> _recordPayment() async {
    if (!_canRecord) return;

    final form = GlobalKey<FormState>();
    final amount = TextEditingController();
    final reference = TextEditingController();
    final notes = TextEditingController();

    PaymentMethod method = PaymentMethod.cash;

    try {
      await _showSheet(
        title: 'Record a payment',
        subtitle: 'Remaining balance: ${_money(_remaining)}',
        child: StatefulBuilder(
          builder: (ctx, update) => Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GWidgetTextField(
                  controller: amount,
                  labelText: 'Amount',
                  hintText: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) => _requiredMoney(v, max: _remaining),
                ),
                const SizedBox(height: 13),
                GWidgetDropDown<PaymentMethod>(
                  labelText: 'Payment method',
                  value: method,
                  items: PaymentMethod.values.map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(
                        PaymentMethodSwitch(
                          paymentMethodEnum: m,
                        ).getText(),
                      ),
                    );
                  }).toList(),
                  onChanged: (m) {
                    if (m != null) {
                      update(() => method = m);
                    }
                  },
                ),
                const SizedBox(height: 13),
                GWidgetTextField(
                  controller: reference,
                  labelText: 'Transaction reference',
                  hintText: method == PaymentMethod.cash
                      ? 'Optional for cash'
                      : 'Required',
                  validator: (v) => method != PaymentMethod.cash &&
                          (v?.trim().isEmpty ?? true)
                      ? 'Reference is required'
                      : null,
                ),
                const SizedBox(height: 13),
                GWidgetTextField(
                  controller: notes,
                  labelText: 'Notes',
                  maxLines: 2,
                  validator: (v) => method == PaymentMethod.other &&
                          (v?.trim().isEmpty ?? true)
                      ? 'Explain other payment method'
                      : null,
                ),
                const SizedBox(height: 20),
                GWidgetButton(
                  text: 'Save payment',
                  fontSize: 15,
                  onPressed: () async {
                    if (form.currentState?.validate() != true) {
                      return;
                    }

                    final success = await _runAction(
                      () => _dataSource.recordPayment(
                        RecordInvoicePaymentParameters(
                          invoiceId: i.id!,
                          amount: double.parse(amount.text.trim()),
                          paymentMethod: method,
                          referenceNumber: reference.text.trim(),
                          notes: notes.text.trim(),
                        ),
                      ),
                    );
                    if (success && ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } finally {
      amount.dispose();
      reference.dispose();
      notes.dispose();
    }
  }

  // ======================================================
  // ACTION 3: EDIT DRAFT INVOICE
  // ======================================================

  Future<void> _editDraft() async {
    if (!_canEdit) return;

    if (i.subtotal == null || i.discountAmount == null || i.taxAmount == null) {
      _info('Invoice pricing is incomplete.');
      return;
    }

    final form = GlobalKey<FormState>();

    final discount = TextEditingController(
      text: i.discountAmount.toString(),
    );

    final tax = TextEditingController(
      text: i.taxAmount.toString(),
    );

    final notes = TextEditingController(
      text: i.notes ?? '',
    );

    try {
      await _showSheet(
        title: 'Edit draft invoice',
        subtitle: 'Subtotal ${_money(i.subtotal)} · only before issue',
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GWidgetTextField(
                controller: discount,
                labelText: 'Discount',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => _requiredMoney(
                  v,
                  max: i.subtotal!.toDouble(),
                  allowZero: true,
                ),
              ),
              const SizedBox(height: 13),
              GWidgetTextField(
                controller: tax,
                labelText: 'Tax amount',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => _requiredMoney(
                  v,
                  max: 999999999,
                  allowZero: true,
                ),
              ),
              const SizedBox(height: 13),
              GWidgetTextField(
                controller: notes,
                labelText: 'Invoice notes',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              GWidgetButton(
                text: 'Save changes',
                fontSize: 15,
                onPressed: () async {
                  if (form.currentState?.validate() != true) {
                    return;
                  }

                  final newTotal = i.subtotal!.toDouble() -
                      double.parse(discount.text) +
                      double.parse(tax.text);

                  if (newTotal < 0 || newTotal < _paid) {
                    _info(
                      'New total cannot be negative or below paid amount.',
                    );
                    return;
                  }

                  final success = await _runAction(
                    () => _dataSource.updateDraftInvoice(
                      UpdateDraftInvoiceParameters(
                        invoiceId: i.id!,
                        discountAmount: double.parse(discount.text.trim()),
                        taxAmount: double.parse(tax.text.trim()),
                        notes: notes.text.trim(),
                      ),
                    ),
                  );
                  if (success && context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    } finally {
      discount.dispose();
      tax.dispose();
      notes.dispose();
    }
  }

  // ======================================================
  // ACTION 4: REFUND
  // ======================================================

  Future<void> _refundPayment() async {
    if (!_canRefund) return;

    final form = GlobalKey<FormState>();
    final amount = TextEditingController();
    final reason = TextEditingController();

    try {
      await _showSheet(
        title: 'Refund payment',
        subtitle: 'Refunds require a verified payment ledger.',
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GWidgetTextField(
                controller: amount,
                labelText: 'Refund amount',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => _requiredMoney(
                  v,
                  max: _paid,
                ),
              ),
              const SizedBox(height: 13),
              GWidgetTextField(
                controller: reason,
                labelText: 'Reason',
                maxLines: 3,
                validator: (v) => (v?.trim().length ?? 0) < 8
                    ? 'Enter at least 8 characters'
                    : null,
              ),
              const SizedBox(height: 20),
              GWidgetButton(
                text: 'Confirm refund',
                fontSize: 15,
                backgroundColor: AppColors.statOrange,
                onPressed: () async {
                  if (form.currentState?.validate() != true) {
                    return;
                  }

                  final success = await _runAction(
                    () => _dataSource.refundPayment(
                      RefundInvoicePaymentParameters(
                        invoiceId: i.id!,
                        amount: double.parse(amount.text.trim()),
                        reason: reason.text.trim(),
                      ),
                    ),
                  );
                  if (success && context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    } finally {
      amount.dispose();
      reason.dispose();
    }
  }

  // ======================================================
  // SCREEN UI
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final progress = _total > 0 ? (_paid / _total).clamp(0.0, 1.0) : 0.0;

    final overdue = i.dueDate != null &&
        i.dueDate!.isBefore(DateTime.now()) &&
        _remaining > 0 &&
        !_terminal;

    return GWidgetNaviBody(
      title: 'Invoice details',
      body: GWidgetLoading(
        isLoading: _busy || _loading,
        body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _refreshInvoice,
            child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 25, 16, 32),
            children: [
              // -----------------------------------------
              // Invoice title + status
              // -----------------------------------------

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      i.invoiceNumber ?? 'Invoice',
                      style: AppFonts(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  InvDetailWidgetBadge(
                    text: PaymentStatusSwitch(
                            paymentStatusEnum: i.paymentStatus)
                        .getText(),
                    color: PaymentStatusSwitch(
                            paymentStatusEnum: i.paymentStatus)
                        .getColor(),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // -----------------------------------------
              // Financial hero card
              // -----------------------------------------

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i.paymentStatus == PaymentStatus.refunded
                          ? 'Refund completed'
                          : _paidInFull
                              ? 'Amount paid'
                              : 'Remaining balance',
                      style: AppFonts(
                        color: AppColors.surfaceWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _money(
                        i.paymentStatus == PaymentStatus.refunded
                            ? _total
                            : _paidInFull ? _paid : _remaining,
                      ),
                      style: AppFonts(
                        color: AppColors.surfaceWhite,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: LinearProgressIndicator(
                        value: progress.toDouble(),
                        minHeight: 7,
                        backgroundColor:
                            AppColors.surfaceWhite.withValues(alpha: .26),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.surfaceWhite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Paid ${_money(_paid)}',
                          style: AppFonts(
                            color: AppColors.surfaceWhite,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Total ${_money(_total)}',
                          style: AppFonts(
                            color: AppColors.surfaceWhite,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (overdue) ...[
                const SizedBox(height: 10),
                InvDetailWidgetBadge(
                  text: 'Overdue since ${_date(i.dueDate)}',
                  color: AppColors.statOrange,
                ),
              ],

              if (!_storageReady ||
                  !_hasId ||
                  !_hasCompleteAmounts ||
                  i.paymentStatus == null) ...[
                const SizedBox(height: 12),
                Text(
                  'Invoice data or local storage is unavailable. '
                  'Financial actions are locked.',
                  style: AppFonts(
                    color: AppColors.statOrange,
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // -----------------------------------------
              // Customer and linked visit
              // -----------------------------------------

              InvDetailWidgetPanel(
                title: 'Customer & visit',
                icon: Icons.home_repair_service_outlined,
                child: Column(
                  children: [
                    InvDetailWidgetInfoLine(
                      label: 'Customer',
                      value: i.client?.name ?? '—',
                    ),
                    InvDetailWidgetInfoLine(
                      label: 'Visit number',
                      value: i.visitNumber ?? '—',
                    ),
                    InvDetailWidgetInfoLine(
                      label: 'Location',
                      value: i.site?.addressDetail ?? '—',
                    ),
                    InvDetailWidgetInfoLine(
                      label: 'Due date',
                      value: _date(i.dueDate),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // -----------------------------------------
              // Financial breakdown
              // -----------------------------------------

              InvDetailWidgetPanel(
                title: 'Amount breakdown',
                icon: Icons.calculate_outlined,
                child: Column(
                  children: [
                    InvDetailWidgetInfoLine(
                      label: 'Subtotal',
                      value: _money(i.subtotal),
                    ),
                    InvDetailWidgetInfoLine(
                      label: 'Discount',
                      value: '- ${_money(i.discountAmount)}',
                    ),
                    InvDetailWidgetInfoLine(
                      label: 'Tax',
                      value: _money(i.taxAmount),
                    ),
                    Divider(
                      color: AppColors.iconLightGrey.withValues(alpha: .5),
                    ),
                    InvDetailWidgetInfoLine(
                      label: 'Invoice total',
                      value: _money(i.totalAmount),
                      emphasize: true,
                      valueColor: AppColors.primary,
                    ),
                    InvDetailWidgetInfoLine(
                      label: 'Paid',
                      value: _money(i.paidAmount),
                      valueColor: AppColors.statGreen,
                    ),
                    InvDetailWidgetInfoLine(
                      label: 'Remaining',
                      value: _money(i.remainingAmount),
                      emphasize: true,
                    ),
                  ],
                ),
              ),

              // -----------------------------------------
              // Optional notes
              // -----------------------------------------

              if ((i.notes ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                InvDetailWidgetPanel(
                  title: 'Notes',
                  icon: Icons.sticky_note_2_outlined,
                  child: Text(
                    i.notes!,
                    style: AppFonts(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 17),

              // -----------------------------------------
              // Context-aware actions
              // Only show relevant actions.
              // -----------------------------------------

              if (_canRecord)
                GWidgetButton(
                  text: 'Record payment',
                  widget: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.add_card_rounded,
                      color: AppColors.surfaceWhite,
                      size: 19,
                    ),
                  ),
                  fontSize: 15,
                  onPressed: _recordPayment,
                ),

              if (_canIssue)
                GWidgetButton(
                  text: 'Issue invoice',
                  fontSize: 15,
                  onPressed: _issueInvoice,
                ),

              if (_canEdit || _canRefund) ...[
                const SizedBox(height: 9),
                OutlinedButton.icon(
                  onPressed: _canEdit ? _editDraft : _refundPayment,
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        _canEdit ? AppColors.primary : AppColors.statOrange,
                    side: BorderSide(
                      color:
                          _canEdit ? AppColors.primary : AppColors.statOrange,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: Icon(
                    _canEdit ? Icons.edit_outlined : Icons.undo_rounded,
                  ),
                  label: Text(
                    _canEdit ? 'Edit draft' : 'Refund payment',
                    style: AppFonts(
                      color:
                          _canEdit ? AppColors.primary : AppColors.statOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],

              if (!(_canIssue || _canEdit || _canRecord || _canRefund))
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'No financial actions available '
                      'for this invoice.',
                      textAlign: TextAlign.center,
                      style: AppFonts(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Changes are saved locally on this device.',
                  style: AppFonts(
                    color: AppColors.textLightHint,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ), // ListView
          ), // RefreshIndicator
          ), // ConstrainedBox
        ), // Center
      ), // GWidgetLoading
    );
  }
}
