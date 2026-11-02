import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../invoices/presentation/screens/invoice_detail_scr.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/visit_rules.dart';
import 'sheets/visit_detail_widget_collect_sheet.dart';
import 'visit_detail_widget_action_sheet.dart';
import 'visit_detail_helpers.dart';
import 'visit_detail_widget_parts.dart';

/// Invoice summary. The admin manages the invoice (issue, edit, payments,
/// confirmations, refunds) on the invoice detail screen; the technician
/// sees what is owed and records what the client pays on site.
class VisitDetailWidgetInvoice extends StatelessWidget {
  const VisitDetailWidgetInvoice({
    super.key,
    required this.visit,
    required this.invoice,
    required this.loading,
    required this.onInvoiceClosed,
  });

  final VisitDetailModel visit;
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
                if ((invoice.pendingAmount ?? 0) > 0) ...[
                  const SizedBox(height: 10),
                  VisitDetailNotice(
                    text: '{0} collected on site is awaiting admin confirmation'
                        .trArgs([
                      VisitDetailHelpers.money(
                          invoice.pendingAmount, invoice.currency)
                    ]),
                    color: AppTheme.pending,
                    icon: Icons.hourglass_top_rounded,
                  ),
                ],
                if (invoice.dueDate != null) ...[
                  const SizedBox(height: 10),
                  _DueDate(invoice: invoice),
                ],
                if (VisitRules.canCollectPayment(visit, invoice)) ...[
                  const SizedBox(height: 14),
                  GWidgetButton(
                    text: 'Collect payment'.tr,
                    fontSize: AppTheme.textSubtitle,
                    raduis: 14,
                    height: 48,
                    backgroundColor: AppTheme.statGreen,
                    widget: Padding(
                      padding: EdgeInsetsDirectional.only(start: 8),
                      child: Icon(Icons.payments_rounded,
                          color: AppTheme.onPrimary, size: 20),
                    ),
                    onPressed: () => VisitDetailWidgetActionSheet.show(
                        context, const VisitDetailWidgetCollectSheet()),
                  ),
                ] else if (!VisitRules.canManageInvoice() &&
                    invoice.issueDate == null) ...[
                  const SizedBox(height: 10),
                  VisitDetailNotice(
                    text:
                        'The invoice is issued when the visit is completed. You can collect payment then.'
                            .tr,
                    color: AppTheme.secondary,
                  ),
                ],
                if (invoice.id != null && VisitRules.canManageInvoice()) ...[
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
