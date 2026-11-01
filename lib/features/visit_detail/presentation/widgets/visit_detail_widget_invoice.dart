import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../invoices/presentation/screens/invoice_detail_scr.dart';
import 'visit_detail_helpers.dart';
import 'visit_detail_widget_parts.dart';

/// Read-only invoice summary. Every invoice action (issue, edit,
/// payments, refunds) lives on the invoice detail screen.
class VisitDetailWidgetInvoice extends StatelessWidget {
  const VisitDetailWidgetInvoice({
    super.key,
    required this.invoice,
    required this.loading,
    required this.onInvoiceClosed,
  });

  final InvoiceDetailModel? invoice;
  final bool loading;

  /// Called after returning from the invoice screen, to reload the visit.
  final VoidCallback onInvoiceClosed;

  Future<void> _openInvoice(BuildContext context, String invoiceID) async {
    await Navigator.pushNamed(context, InvoiceDetailScr.route,
        arguments: InvoiceDetailArgu(invoiceID: invoiceID).toArgu());
    onInvoiceClosed();
  }

  @override
  Widget build(BuildContext context) {
    final invoice = this.invoice;

    return VisitDetailSection(
      title: 'Invoice'.tr,
      icon: Icons.receipt_long_rounded,
      color: AppTheme.statGreen,
      child: invoice == null
          ? (loading
              ? Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                      child: GWidgetLoadingCircle(
                          color: AppTheme.statGreen,
                          strokeWidth: 3,
                          width: 26,
                          height: 26)),
                )
              : VisitDetailEmpty(
                  icon: Icons.receipt_outlined,
                  text: 'No invoice is linked to this visit'.tr))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InvoiceHeader(invoice: invoice),
                const SizedBox(height: 12),
                _BalanceCard(invoice: invoice),
                if (invoice.dueDate != null) ...[
                  const SizedBox(height: 10),
                  _DueDate(invoice: invoice),
                ],
                if (invoice.id != null) ...[
                  const SizedBox(height: 14),
                  GWidgetButton(
                    text: 'Open invoice'.tr,
                    fontSize: AppTheme.textSubtitle,
                    raduis: 14,
                    height: 48,
                    colorText: AppTheme.statGreen,
                    backgroundColor: AppTheme.statGreen.withValues(alpha: .08),
                    border: Border.all(
                        color: AppTheme.statGreen.withValues(alpha: .6)),
                    widget: Padding(
                      padding: EdgeInsetsDirectional.only(start: 8),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: AppTheme.statGreen, size: 20),
                    ),
                    onPressed: () => _openInvoice(context, invoice.id!),
                  ),
                  const SizedBox(height: 6),
                  Text('Issue, edit, payments and refunds are managed there.'.tr,
                      textAlign: TextAlign.center,
                      style: AppTheme.font(
                          color: AppTheme.textLightHint, fontSize: AppTheme.textCaption)),
                ],
              ],
            ),
    );
  }
}

class _InvoiceHeader extends StatelessWidget {
  const _InvoiceHeader({required this.invoice});
  final InvoiceDetailModel invoice;

  @override
  Widget build(BuildContext context) {
    final status = PaymentStatusSwitch(paymentStatusEnum: invoice.paymentStatus);
    final issued = invoice.issueDate != null;

    return Row(
      children: [
        Expanded(
          child: Text(invoice.invoiceNumber ?? 'Invoice'.tr,
              style: AppTheme.font(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.textSubtitle,
                  fontWeight: FontWeight.w800)),
        ),
        VisitDetailPill(
            text: issued
                ? 'Issued {0}'.trArgs([VisitDetailHelpers.date(invoice.issueDate)])
                : 'Draft'.tr,
            color: issued ? AppTheme.secondary : AppTheme.iconGrey),
        const SizedBox(width: 6),
        VisitDetailPill(
            text: VisitDetailHelpers.capitalize(status.getText()),
            color: status.getColor()),
      ],
    );
  }
}

/// Due date, highlighted when money is still owed after it.
class _DueDate extends StatelessWidget {
  const _DueDate({required this.invoice});
  final InvoiceDetailModel invoice;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final overdue = (invoice.remainingAmount ?? 0) > 0 &&
        invoice.paymentStatus != PaymentStatus.cancelled &&
        invoice.dueDate!.isBefore(DateTime(now.year, now.month, now.day));

    return VisitDetailNotice(
      text: overdue
          ? 'Overdue since {0}'.trArgs([VisitDetailHelpers.date(invoice.dueDate)])
          : 'Due by {0}'.trArgs([VisitDetailHelpers.date(invoice.dueDate)]),
      color: overdue ? AppTheme.statOrange : AppTheme.secondary,
      icon: overdue ? Icons.warning_amber_rounded : Icons.event_rounded,
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.invoice});
  final InvoiceDetailModel invoice;

  @override
  Widget build(BuildContext context) {
    final total = invoice.totalAmount ?? 0;
    final paid = invoice.paidAmount ?? 0;
    final progress = total > 0 ? (paid / total).clamp(0.0, 1.0).toDouble() : 0.0;
    final fullyPaid = invoice.paymentStatus == PaymentStatus.paid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AppTheme.statGreen, AppTheme.secondary],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fullyPaid ? 'Amount paid'.tr : 'Remaining balance'.tr,
              style: AppTheme.font(
                  color: AppTheme.onPrimary.withValues(alpha: .9),
                  fontSize: AppTheme.textSmall,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
              VisitDetailHelpers.money(
                  fullyPaid ? paid : invoice.remainingAmount, invoice.currency),
              style: AppTheme.font(
                  color: AppTheme.onPrimary,
                  fontSize: AppTheme.textDisplay,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppTheme.surface.withValues(alpha: .28),
              valueColor:
                  AlwaysStoppedAnimation(AppTheme.onPrimary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Paid {0}'.trArgs([VisitDetailHelpers.money(paid, invoice.currency)]),
                  style: AppTheme.font(color: AppTheme.onPrimary, fontSize: AppTheme.textSmall)),
              Text('Total {0}'.trArgs([VisitDetailHelpers.money(total, invoice.currency)]),
                  style: AppTheme.font(color: AppTheme.onPrimary, fontSize: AppTheme.textSmall)),
            ],
          ),
        ],
      ),
    );
  }
}
