import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/features/invoices/domain/usecases/get_invoice_detail_uc.dart';
import 'package:visit_proof/features/invoices/domain/usecases/issue_invoice_uc.dart';
import 'package:visit_proof/features/invoices/presentation/controller/invoices_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../../../core/utils/general_widgets/g_widget_navi_body.dart';
import '../../../data/models/invoice_detail_model.dart';
import '../../../data/models/invoice_payment_history_model.dart';
import '../../../domain/usecases/get_payments_uc.dart';
import '../payments_widgets/payments_widget_review.dart';
import '../payments_widgets/payments_widget_tile.dart';
import 'inv_detail_widget_edit_sheet.dart';
import 'inv_detail_widget_record_payment_sheet.dart';
import 'inv_detail_widget_refund_payment_sheet.dart';
import 'invoice_detail_parts.dart';

class InvoiceDetailBody extends StatefulWidget {
  const InvoiceDetailBody(
      {super.key,
      required this.invoice,
      required this.loading,
      this.payments = const [],
      this.reviewing = false});
  final InvoiceDetailModel invoice;
  final bool loading;

  /// The invoice's ledger, newest first.
  final List<InvoicePaymentHistoryModel> payments;
  final bool reviewing;

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
          widget.invoice.paymentStatus == PaymentStatus.partiallyPaid ||
          widget.invoice.paymentStatus == PaymentStatus.pending) &&
      _hasCompleteAmounts &&
      _collectible > 0;

  /// The balance minus field collections still waiting for confirmation.
  double get _collectible {
    final cents = (((widget.invoice.remainingAmount ?? 0) -
                (widget.invoice.pendingAmount ?? 0)) *
            100)
        .round();
    return cents <= 0 ? 0 : cents / 100;
  }

  num get _pending => widget.invoice.pendingAmount ?? 0;

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
      return 'Enter a valid amount (up to 2 decimals)'.tr;
    }

    final number = double.tryParse(v);

    if (number == null ||
        !number.isFinite ||
        (allowZero ? number < 0 : number <= 0)) {
      return allowZero
          ? 'Amount cannot be negative'.tr
          : 'Amount must be above zero'.tr;
    }

    if (number > max + 0.001) {
      return 'Maximum allowed: {0}'.trArgs([_money(max)]);
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
      AppToasts.showMessage('Complete client, currency and invoice amounts.'.tr,
          color: AppTheme.primary);
      return;
    }

    if (((widget.invoice.subtotal! -
                    widget.invoice.discountAmount! +
                    widget.invoice.taxAmount!) -
                (widget.invoice.totalAmount ?? 0).toDouble())
            .abs() >
        .011) {
      AppToasts.showMessage('Invoice breakdown does not match the total.'.tr,
          color: AppTheme.primary);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Issue invoice?'.tr,
          style: AppTheme.font(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Total: {0}\nCheck the linked visit before confirming.'.trArgs([_money((widget.invoice.totalAmount ?? 0).toDouble())]),
          style: AppTheme.font(
            color: AppTheme.textSecondary,
            fontSize: AppTheme.textBodyLarge,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Back'.tr,
              style: AppTheme.font(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Continue'.tr,
              style: AppTheme.font(
                color: AppTheme.primary,
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
    context.read<InvoicesBloc>()
      ..add(GetInvoiceDetailEvent(
          getInvoiceDetailParameters:
              GetInvoiceDetailParameters(invoiceId: widget.invoice.id!)))
      ..add(GetPaymentsEvent(
          getPaymentsParameters:
              GetPaymentsParameters(invoiceId: widget.invoice.id!)));
  }

  Widget _payments() {
    final pending = widget.payments.where((e) => e.isPending).length;
    return InvDetailWidgetPanel(
      title: pending > 0
          ? 'Payments ({0} awaiting confirmation)'.trArgs([pending])
          : 'Payments'.tr,
      icon: Icons.payments_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final payment in widget.payments) ...[
            PaymentsWidgetTile(
              payment: payment,
              currency: widget.invoice.currency,
              reviewing: widget.reviewing,
              onConfirm: () => PaymentsWidgetReview.confirm(context, payment,
                  currency: widget.invoice.currency),
              onReject: () => PaymentsWidgetReview.reject(context, payment),
            ),
            if (payment != widget.payments.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
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
      title: 'Invoice details'.tr,
      body: GWidgetLoading(
        isLoading: widget.loading,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: RefreshIndicator(
              color: AppTheme.primary,
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
                          widget.invoice.invoiceNumber ?? 'Invoice'.tr,
                          style: AppTheme.font(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.textTitle,
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
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.invoice.paymentStatus == PaymentStatus.refunded
                              ? 'Refund completed'.tr
                              : (widget.invoice.paymentStatus ==
                                      PaymentStatus.paid)
                                  ? 'Amount paid'.tr
                                  : 'Remaining balance'.tr,
                          style: AppTheme.font(
                            color: AppTheme.onPrimary,
                            fontSize: AppTheme.textBody,
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
                          style: AppTheme.font(
                            color: AppTheme.onPrimary,
                            fontSize: AppTheme.textDisplay,
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
                                AppTheme.surface.withValues(alpha: .26),
                            valueColor: AlwaysStoppedAnimation(
                              AppTheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Paid {0}'.trArgs([_money((widget.invoice.paidAmount ?? 0).toDouble())]),
                              style: AppTheme.font(
                                color: AppTheme.onPrimary,
                                fontSize: AppTheme.textSmall,
                              ),
                            ),
                            Text(
                              'Total {0}'.trArgs([_money((widget.invoice.totalAmount ?? 0).toDouble())]),
                              style: AppTheme.font(
                                color: AppTheme.onPrimary,
                                fontSize: AppTheme.textSmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (_pending > 0) ...[
                    const SizedBox(height: 10),
                    InvDetailWidgetBadge(
                      text: '{0} collected by the technician is awaiting your confirmation'
                          .trArgs([_money(_pending)]),
                      color: AppTheme.pending,
                    ),
                  ],

                  if (overdue) ...[
                    const SizedBox(height: 10),
                    InvDetailWidgetBadge(
                      text: 'Overdue since {0}'.trArgs([_date(widget.invoice.dueDate)]),
                      color: AppTheme.statOrange,
                    ),
                  ],

                  if (!_hasId ||
                      !_hasCompleteAmounts ||
                      widget.invoice.paymentStatus == null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Invoice data or local storage is unavailable. Financial actions are locked.'.tr,
                      style: AppTheme.font(
                        color: AppTheme.statOrange,
                        fontSize: AppTheme.textBody,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // -----------------------------------------
                  // Customer and linked visit
                  // -----------------------------------------

                  InvDetailWidgetPanel(
                    title: 'Customer & visit'.tr,
                    icon: Icons.home_repair_service_outlined,
                    child: Column(
                      children: [
                        InvDetailWidgetInfoLine(
                          label: 'Customer'.tr,
                          value: widget.invoice.client?.name ?? '—',
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Visit number'.tr,
                          value: widget.invoice.visitNumber ?? '—',
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Location'.tr,
                          value: widget.invoice.site?.addressDetail ?? '—',
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Due date'.tr,
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
                    title: 'Amount breakdown'.tr,
                    icon: Icons.calculate_outlined,
                    child: Column(
                      children: [
                        InvDetailWidgetInfoLine(
                          label: 'Subtotal'.tr,
                          value: _money(widget.invoice.subtotal),
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Discount'.tr,
                          value: '- ${_money(widget.invoice.discountAmount)}',
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Tax'.tr,
                          value: _money(widget.invoice.taxAmount),
                        ),
                        Divider(
                          color: AppTheme.iconLightGrey.withValues(alpha: .5),
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Invoice total'.tr,
                          value: _money(widget.invoice.totalAmount),
                          emphasize: true,
                          valueColor: AppTheme.primary,
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Paid'.tr,
                          value: _money(widget.invoice.paidAmount),
                          valueColor: AppTheme.statGreen,
                        ),
                        InvDetailWidgetInfoLine(
                          label: 'Remaining'.tr,
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
                      title: 'Notes'.tr,
                      icon: Icons.sticky_note_2_outlined,
                      child: Text(
                        widget.invoice.notes!,
                        style: AppTheme.font(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.textBody,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  if (widget.payments.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _payments(),
                  ],

                  const SizedBox(height: 17),

                  // -----------------------------------------
                  // Context-aware actions
                  // Only show relevant actions.
                  // -----------------------------------------

                  if (_canRecord)
                    GWidgetButton(
                        text: 'Record payment'.tr,
                        widget: Padding(
                          padding: EdgeInsetsDirectional.only(start: 8),
                          child: Icon(
                            Icons.add_card_rounded,
                            color: AppTheme.onPrimary,
                            size: 19,
                          ),
                        ),
                        fontSize: AppTheme.textSubtitle,
                        onPressed: () async {
                          final data = await AppToasts.showBottomSheet(
                              context,
                              InvDetailWidgetRecordPaymentSheet(
                                  invoiceID: widget.invoice.id!,
                                  subtitle: 'Remaining balance: {0}'
                                      .trArgs([_money(_collectible)]),
                                  validator: (v) =>
                                      _requiredMoney(v, max: _collectible)));
                          if (data == true) {
                            _getInvoiceDetail();
                          }
                        }),

                  if (_canIssue)
                    GWidgetButton(
                      text: 'Issue invoice'.tr,
                      fontSize: AppTheme.textSubtitle,
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
                                    color: AppTheme.primary,
                                    'Invoice pricing is incomplete.'.tr);
                                return;
                              }
                              final data = await AppToasts.showBottomSheet(
                                  context,
                                  InvDetailWidgetEditSheet(
                                    invoice: widget.invoice,
                                    subtitle:
                                        'Subtotal {0} · only before issue'.trArgs([_money(widget.invoice.subtotal)]),
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
                            _canEdit ? AppTheme.primary : AppTheme.statOrange,
                        side: BorderSide(
                          color: _canEdit
                              ? AppTheme.primary
                              : AppTheme.statOrange,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(
                        _canEdit ? Icons.edit_outlined : Icons.undo_rounded,
                      ),
                      label: Text(
                        _canEdit ? 'Edit draft'.tr : 'Refund payment'.tr,
                        style: AppTheme.font(
                          color: _canEdit
                              ? AppTheme.primary
                              : AppTheme.statOrange,
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
                          'No financial actions available for this invoice.'.tr,
                          textAlign: TextAlign.center,
                          style: AppTheme.font(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.textBody,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      'Changes are saved locally on this device.'.tr,
                      style: AppTheme.font(
                        color: AppTheme.textLightHint,
                        fontSize: AppTheme.textCaption,
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
