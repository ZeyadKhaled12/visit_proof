import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/features/invoices/domain/usecases/get_invoice_detail_uc.dart';
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
  bool get _hasId =>
      (widget.invoice.id?.trim().isNotEmpty ?? false) &&
      (widget.invoice.visitId?.trim().isNotEmpty ?? false);

  bool get _hasCompleteAmounts =>
      widget.invoice.totalAmount != null &&
      widget.invoice.paidAmount != null &&
      widget.invoice.remainingAmount != null &&
      widget.invoice.totalAmount!.toDouble().isFinite &&
      widget.invoice.paidAmount!.toDouble().isFinite &&
      widget.invoice.remainingAmount!.toDouble().isFinite &&
      widget.invoice.totalAmount! >= 0 &&
      widget.invoice.paidAmount! >= 0 &&
      widget.invoice.remainingAmount! >= 0 &&
      (widget.invoice.totalAmount! -
                  widget.invoice.paidAmount! -
                  widget.invoice.remainingAmount!)
              .abs() <
          0.011;

  // IMPORTANT:
  // issueDate is only a UI hint, NOT a replacement for InvoiceStatus.
  //
  // Existing model uses issueDate as draft / issued marker.
  // Linked VisitStatus and payment history are validated by the source.

  bool get _canIssue =>
      _hasId &&
      widget.invoice.issueDate == null &&
      widget.invoice.paymentStatus == PaymentStatus.unpaid &&
      _hasCompleteAmounts &&
      widget.invoice.paidAmount == 0 &&
      (widget.invoice.totalAmount ?? 0) > 0;

  bool get _canEdit =>
      _hasId &&
      widget.invoice.issueDate == null &&
      widget.invoice.paymentStatus == PaymentStatus.unpaid &&
      _hasCompleteAmounts &&
      widget.invoice.paidAmount == 0;

  bool get _canRecord =>
      _hasId &&
      widget.invoice.issueDate != null &&
      widget.invoice.paymentStatus != PaymentStatus.cancelled &&
      widget.invoice.paymentStatus != PaymentStatus.refunded &&
      (widget.invoice.paymentStatus == PaymentStatus.unpaid ||
          widget.invoice.paymentStatus == PaymentStatus.partiallyPaid) &&
      _hasCompleteAmounts &&
      (widget.invoice.remainingAmount ?? 0) > 0;

  bool get _canRefund =>
      _hasId &&
      widget.invoice.issueDate != null &&
      widget.invoice.paymentStatus != PaymentStatus.cancelled &&
      widget.invoice.paymentStatus != PaymentStatus.refunded &&
      (widget.invoice.paymentStatus == PaymentStatus.partiallyPaid ||
          widget.invoice.paymentStatus == PaymentStatus.paid) &&
      _hasCompleteAmounts &&
      (widget.invoice.paidAmount ?? 0) > 0;

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
                (widget.invoice.totalAmount ?? 0).toDouble())
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
          'Total: ${_money((widget.invoice.totalAmount ?? 0).toDouble())}\n'
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

  void _getInvoiceDetail() {
    if (widget.invoice.id == null) return;
    context.read<InvoicesBloc>().add(GetInvoiceDetailEvent(
        getInvoiceDetailParameters:
            GetInvoiceDetailParameters(invoiceId: widget.invoice.id!)));
  }

  // ======================================================
  // SCREEN UI
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final progress = (widget.invoice.totalAmount ?? 0) > 0
        ? ((widget.invoice.paidAmount ?? 0) / widget.invoice.totalAmount!)
            .clamp(0.0, 1.0)
            .toDouble()
        : 0.0;

    final overdue = widget.invoice.dueDate != null &&
        widget.invoice.dueDate!.isBefore(DateTime.now()) &&
        (widget.invoice.remainingAmount ?? 0) > 0 &&
        widget.invoice.paymentStatus != PaymentStatus.cancelled &&
        widget.invoice.paymentStatus != PaymentStatus.refunded;
    return GWidgetNaviBody(
      title: 'Invoice details',
      body: GWidgetLoading(
        isLoading: widget.loading,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                _getInvoiceDetail();
              },
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
                              : (widget.invoice.paymentStatus ==
                                      PaymentStatus.paid)
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
                                ? (widget.invoice.totalAmount ?? 0).toDouble()
                                : (widget.invoice.paymentStatus ==
                                        PaymentStatus.paid)
                                    ? (widget.invoice.paidAmount ?? 0)
                                        .toDouble()
                                    : (widget.invoice.remainingAmount ?? 0)
                                        .toDouble(),
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
                              'Paid ${_money((widget.invoice.paidAmount ?? 0).toDouble())}',
                              style: AppFonts(
                                color: AppColors.surfaceWhite,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Total ${_money((widget.invoice.totalAmount ?? 0).toDouble())}',
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
                        onPressed: () async {
                          final data = await AppToasts.showBottomSheet(
                              context,
                              InvDetailWidgetRecordPaymentSheet(
                                  invoiceID: widget.invoice.id!,
                                  subtitle:
                                      'Remaining balance: ${_money((widget.invoice.remainingAmount ?? 0).toDouble())}',
                                  validator: (v) => _requiredMoney(v,
                                      max: (widget.invoice.remainingAmount ?? 0)
                                          .toDouble())));
                          if (data == true) {
                            _getInvoiceDetail();
                          }
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
                          ? () async {
                              if (widget.invoice.subtotal == null ||
                                  widget.invoice.discountAmount == null ||
                                  widget.invoice.taxAmount == null) {
                                AppToasts.showMessage(
                                    color: AppColors.primary,
                                    'Invoice pricing is incomplete.');
                                return;
                              }
                              final data = await AppToasts.showBottomSheet(
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
                              if (data == true) {
                                _getInvoiceDetail();
                              }
                            }
                          : () async {
                              final data = await AppToasts.showBottomSheet(
                                  context,
                                  InvDetailWidgetRefundPaymentSheet(
                                      invoiceID: widget.invoice.id!,
                                      validator: (v) => _requiredMoney(
                                            v,
                                            max:
                                                (widget.invoice.paidAmount ?? 0)
                                                    .toDouble(),
                                          )));
                              if (data == true) {
                                _getInvoiceDetail();
                              }
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
