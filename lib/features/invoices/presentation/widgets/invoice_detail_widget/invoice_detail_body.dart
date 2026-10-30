import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/features/invoices/domain/usecases/issue_invoice_uc.dart';
import 'package:visit_proof/features/invoices/presentation/controller/invoices_bloc.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';
import '../../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../../../core/utils/general_widgets/g_widget_navi_body.dart';
import '../../../data/models/invoice_detail_model.dart';
import 'inv_detail_widget_edit_sheet.dart';
import 'inv_detail_widget_record_payment_sheet.dart';
import 'inv_detail_widget_refund_payment_sheet.dart';
import 'invoice_detail_parts.dart';

class InvoiceDetailBody extends StatefulWidget {
  const InvoiceDetailBody(
      {super.key, required this.invoice, required this.loading});
  final InvoiceDetailModel invoice;
  final bool loading;

  @override
  State<InvoiceDetailBody> createState() => _InvoiceDetailBodyState();
}

class _InvoiceDetailBodyState extends State<InvoiceDetailBody> {
  double get _total => widget.invoice.totalAmount?.toDouble() ?? 0;
  double get _paid => widget.invoice.paidAmount?.toDouble() ?? 0;
  double get _remaining => widget.invoice.remainingAmount?.toDouble() ?? 0;

  bool get _hasId =>
      (widget.invoice.id?.trim().isNotEmpty ?? false) &&
      (widget.invoice.visitId?.trim().isNotEmpty ?? false);

  bool get _hasCompleteAmounts =>
      widget.invoice.totalAmount != null &&
      widget.invoice.paidAmount != null &&
      widget.invoice.remainingAmount != null &&
      _total.isFinite &&
      _paid.isFinite &&
      _remaining.isFinite &&
      _total >= 0 &&
      _paid >= 0 &&
      _remaining >= 0 &&
      (_total - _paid - _remaining).abs() < 0.011;

  bool get _terminal =>
      widget.invoice.paymentStatus == PaymentStatus.cancelled ||
      widget.invoice.paymentStatus == PaymentStatus.refunded;

  bool get _unpaid => widget.invoice.paymentStatus == PaymentStatus.unpaid;

  bool get _partial =>
      widget.invoice.paymentStatus == PaymentStatus.partiallyPaid;

  bool get _paidInFull => widget.invoice.paymentStatus == PaymentStatus.paid;

  bool get _hasIssueDate => widget.invoice.issueDate != null;

  // IMPORTANT:
  // issueDate is only a UI hint, NOT a replacement for InvoiceStatus.
  //
  // Existing model uses issueDate as draft / issued marker.
  // Linked VisitStatus and payment history are validated by the source.

  bool get _canIssue =>
      _hasId &&
      !_hasIssueDate &&
      _unpaid &&
      _hasCompleteAmounts &&
      _paid == 0 &&
      _total > 0;

  bool get _canEdit =>
      _hasId && !_hasIssueDate && _unpaid && _hasCompleteAmounts && _paid == 0;

  bool get _canRecord =>
      _hasId &&
      _hasIssueDate &&
      !_terminal &&
      (_unpaid || _partial) &&
      _hasCompleteAmounts &&
      _remaining > 0;

  bool get _canRefund =>
      _hasId &&
      _hasIssueDate &&
      !_terminal &&
      (_partial || _paidInFull) &&
      _hasCompleteAmounts &&
      _paid > 0;

  String _money(num? amount) =>
      '${(amount ?? 0).toStringAsFixed(2)} ${widget.invoice.currency ?? ''}'
          .trim();

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

  // ======================================================
  // ACTION 1: ISSUE INVOICE
  // ======================================================

  Future<void> _issueInvoice() async {
    if (!_canIssue) return;

    if (widget.invoice.client?.id == null ||
        widget.invoice.client?.name?.trim().isEmpty != false ||
        widget.invoice.currency?.trim().isEmpty != false ||
        widget.invoice.subtotal == null ||
        widget.invoice.discountAmount == null ||
        widget.invoice.taxAmount == null) {
      AppToasts.showMessage('Complete client, currency and invoice amounts.',
          color: AppColors.primary);
      return;
    }

    if (((widget.invoice.subtotal! -
                    widget.invoice.discountAmount! +
                    widget.invoice.taxAmount!) -
                _total)
            .abs() >
        .011) {
      AppToasts.showMessage('Invoice breakdown does not match the total.',
          color: AppColors.primary);
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
    context.read<InvoicesBloc>().add(IssueInvoiceEvent(
        issueInvoiceParameters:
            IssueInvoiceParameters(invoiceId: widget.invoice.id!)));
  }

  // ======================================================
  // SCREEN UI
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final progress = _total > 0 ? (_paid / _total).clamp(0.0, 1.0) : 0.0;

    final overdue = widget.invoice.dueDate != null &&
        widget.invoice.dueDate!.isBefore(DateTime.now()) &&
        _remaining > 0 &&
        !_terminal;

    return GWidgetNaviBody(
      title: 'Invoice details',
      body: GWidgetLoading(
        isLoading: widget.loading,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {},
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
                          widget.invoice.invoiceNumber ?? 'Invoice',
                          style: AppFonts(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      InvDetailWidgetBadge(
                        text: PaymentStatusSwitch(
                                paymentStatusEnum: widget.invoice.paymentStatus)
                            .getText(),
                        color: PaymentStatusSwitch(
                                paymentStatusEnum: widget.invoice.paymentStatus)
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
                          widget.invoice.paymentStatus == PaymentStatus.refunded
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
                            widget.invoice.paymentStatus ==
                                    PaymentStatus.refunded
                                ? _total
                                : _paidInFull
                                    ? _paid
                                    : _remaining,
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
                      text: 'Overdue since ${_date(widget.invoice.dueDate)}',
                      color: AppColors.statOrange,
                    ),
                  ],

                  if (!_hasId ||
                      !_hasCompleteAmounts ||
                      widget.invoice.paymentStatus == null) ...[
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
                          value: widget.invoice.client?.name ?? '—',
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Visit number',
                          value: widget.invoice.visitNumber ?? '—',
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Location',
                          value: widget.invoice.site?.addressDetail ?? '—',
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Due date',
                          value: _date(widget.invoice.dueDate),
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
                          value: _money(widget.invoice.subtotal),
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Discount',
                          value: '- ${_money(widget.invoice.discountAmount)}',
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Tax',
                          value: _money(widget.invoice.taxAmount),
                        ),
                        Divider(
                          color: AppColors.iconLightGrey.withValues(alpha: .5),
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Invoice total',
                          value: _money(widget.invoice.totalAmount),
                          emphasize: true,
                          valueColor: AppColors.primary,
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Paid',
                          value: _money(widget.invoice.paidAmount),
                          valueColor: AppColors.statGreen,
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Remaining',
                          value: _money(widget.invoice.remainingAmount),
                          emphasize: true,
                        ),
                      ],
                    ),
                  ),

                  // -----------------------------------------
                  // Optional notes
                  // -----------------------------------------

                  if ((widget.invoice.notes ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    InvDetailWidgetPanel(
                      title: 'Notes',
                      icon: Icons.sticky_note_2_outlined,
                      child: Text(
                        widget.invoice.notes!,
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
                        onPressed: () {
                          AppToasts.showBottomSheet(
                              context,
                              InvDetailWidgetRecordPaymentSheet(
                                  invoiceID: widget.invoice.id!,
                                  subtitle:
                                      'Remaining balance: ${_money(_remaining)}',
                                  validator: (v) =>
                                      _requiredMoney(v, max: _remaining)));
                        }),

                  if (_canIssue)
                    GWidgetButton(
                      text: 'Issue invoice',
                      fontSize: 15,
                      onPressed: _issueInvoice,
                    ),

                  if (_canEdit || _canRefund) ...[
                    const SizedBox(height: 9),
                    OutlinedButton.icon(
                      onPressed: _canEdit
                          ? () {
                              if (widget.invoice.subtotal == null ||
                                  widget.invoice.discountAmount == null ||
                                  widget.invoice.taxAmount == null) {
                                AppToasts.showMessage(
                                    color: AppColors.primary,
                                    'Invoice pricing is incomplete.');
                                return;
                              }
                              AppToasts.showBottomSheet(
                                  context,
                                  InvDetailWidgetEditSheet(
                                    invoice: widget.invoice,
                                    subtitle:
                                        'Subtotal ${_money(widget.invoice.subtotal)} · only before issue',
                                    validatorDiscount: (v) => _requiredMoney(
                                      v,
                                      max: widget.invoice.subtotal!.toDouble(),
                                      allowZero: true,
                                    ),
                                    validatorTax: (v) => _requiredMoney(
                                      v,
                                      max: 999999999,
                                      allowZero: true,
                                    ),
                                  ));
                            }
                          : () {
                              AppToasts.showBottomSheet(
                                  context,
                                  InvDetailWidgetRefundPaymentSheet(
                                      invoiceID: widget.invoice.id!,
                                      validator: (v) => _requiredMoney(
                                            v,
                                            max: _paid,
                                          )));
                            },
                      //  _refundPayment,
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            _canEdit ? AppColors.primary : AppColors.statOrange,
                        side: BorderSide(
                          color: _canEdit
                              ? AppColors.primary
                              : AppColors.statOrange,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(
                        _canEdit ? Icons.edit_outlined : Icons.undo_rounded,
                      ),
                      label: Text(
                        _canEdit ? 'Edit draft' : 'Refund payment',
                        style: AppFonts(
                          color: _canEdit
                              ? AppColors.primary
                              : AppColors.statOrange,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
