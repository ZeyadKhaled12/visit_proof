import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums/payment_status_enum.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../invoices/data/models/invoice_payment_history_model.dart';
import '../../../invoices/presentation/screens/invoice_detail_scr.dart';
import '../../../visit_detail/presentation/screens/visit_detail_scr.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../controller/dashboard_bloc.dart';

/// Opens existing record screens and refreshes the dashboard afterwards,
/// since the admin may have changed the record there.
class DashboardNavigation {
  DashboardNavigation._();

  static Future<void> openVisit(BuildContext context, String? visitID) async {
    if (visitID == null) return;
    final bloc = context.read<DashboardBloc>();
    await Navigator.pushNamed(context, VisitDetailScr.route,
        arguments: VisitDetailArgu(visitID: visitID).toArgu());
    bloc.add(const GetDashboardEvent(noParameters: NoParameters()));
  }

  static Future<void> openInvoice(
      BuildContext context, String? invoiceID) async {
    if (invoiceID == null) return;
    final bloc = context.read<DashboardBloc>();
    await Navigator.pushNamed(context, InvoiceDetailScr.route,
        arguments: InvoiceDetailArgu(invoiceID: invoiceID).toArgu());
    bloc.add(const GetDashboardEvent(noParameters: NoParameters()));
  }
}

/// Visit rows (Layer 4 entry): tap opens Visit Details.
class DashboardWidgetVisitList extends StatelessWidget {
  const DashboardWidgetVisitList(
      {super.key, required this.visits, this.limit, this.emptyText});
  final List<VisitDetailModel> visits;
  final int? limit;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) return _Empty(text: emptyText ?? 'No visits to show'.tr);
    final shown = limit == null ? visits : visits.take(limit!).toList();

    return Column(
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0)
            Divider(height: 1, color: AppTheme.iconLightGrey.withValues(alpha: .3)),
          _VisitRow(visit: shown[i]),
        ],
        if (limit != null && visits.length > limit!)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('+ {0} more'.trArgs([visits.length - limit!]),
                style: AppTheme.font(color: AppTheme.textSecondary, fontSize: AppTheme.textSmall)),
          ),
      ],
    );
  }
}

class _VisitRow extends StatelessWidget {
  const _VisitRow({required this.visit});
  final VisitDetailModel visit;

  @override
  Widget build(BuildContext context) {
    final color = VisitDetailHelpers.statusColor(visit.status);

    return InkWell(
      onTap: () => DashboardNavigation.openVisit(context, visit.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${visit.visitNumber ?? 'Visit'} · '
                      '${visit.client?.name ?? 'No client'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.font(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.textBody,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                      '${VisitDetailHelpers.dateTime(visit.startDate)} · '
                      '${visit.technicianModel?.name ?? 'No technician'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.font(
                          color: AppTheme.textSecondary, fontSize: AppTheme.textCaption)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(VisitDetailHelpers.statusText(visit.status),
                style: AppTheme.font(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.textCaption,
                    fontWeight: FontWeight.w700)),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: AppTheme.iconGrey),
          ],
        ),
      ),
    );
  }
}

/// Invoice rows: tap opens Invoice Details.
class DashboardWidgetInvoiceList extends StatelessWidget {
  const DashboardWidgetInvoiceList(
      {super.key, required this.invoices, this.limit, this.emptyText});
  final List<InvoiceDetailModel> invoices;
  final int? limit;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return _Empty(text: emptyText ?? 'No invoices to show'.tr);
    }
    final shown = limit == null ? invoices : invoices.take(limit!).toList();

    return Column(
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0)
            Divider(height: 1, color: AppTheme.iconLightGrey.withValues(alpha: .3)),
          _InvoiceRow(invoice: shown[i]),
        ],
      ],
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.invoice});
  final InvoiceDetailModel invoice;

  @override
  Widget build(BuildContext context) {
    final status = PaymentStatusSwitch(paymentStatusEnum: invoice.paymentStatus);

    return InkWell(
      onTap: () => DashboardNavigation.openInvoice(context, invoice.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                  color: status.getColor(),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${invoice.invoiceNumber ?? 'Invoice'} · '
                      '${invoice.client?.name ?? 'No client'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.font(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.textBody,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                      invoice.dueDate == null
                          ? status.getText()
                          : '{0} · due {1}'.trArgs([status.getText(), VisitDetailHelpers.date(invoice.dueDate)]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.font(
                          color: AppTheme.textSecondary, fontSize: AppTheme.textCaption)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
                VisitDetailHelpers.money(
                    invoice.remainingAmount ?? invoice.totalAmount,
                    invoice.currency),
                style: AppTheme.font(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.textSmall,
                    fontWeight: FontWeight.w800)),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: AppTheme.iconGrey),
          ],
        ),
      ),
    );
  }
}

/// Payment ledger rows: tap opens the paid invoice.
class DashboardWidgetPaymentList extends StatelessWidget {
  const DashboardWidgetPaymentList(
      {super.key, required this.payments, required this.invoices});
  final List<InvoicePaymentHistoryModel> payments;
  final List<InvoiceDetailModel> invoices;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return _Empty(text: 'No payments in this period'.tr);
    }
    final invoiceOf = {for (final i in invoices) i.id: i};

    return Column(
      children: [
        for (var i = 0; i < payments.length; i++) ...[
          if (i > 0)
            Divider(height: 1, color: AppTheme.iconLightGrey.withValues(alpha: .3)),
          _PaymentRow(
              payment: payments[i], invoice: invoiceOf[payments[i].invoiceId]),
        ],
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment, required this.invoice});
  final InvoicePaymentHistoryModel payment;
  final InvoiceDetailModel? invoice;

  @override
  Widget build(BuildContext context) {
    final amount = payment.paymentAmount ?? 0;
    final refund = amount < 0;

    return InkWell(
      onTap: () => DashboardNavigation.openInvoice(context, payment.invoiceId),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(refund ? Icons.undo_rounded : Icons.south_west_rounded,
                size: 18,
                color: refund ? AppTheme.statOrange : AppTheme.statGreen),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${invoice?.invoiceNumber ?? 'Invoice'} · '
                      '${invoice?.client?.name ?? 'Client'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.font(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.textBody,
                          fontWeight: FontWeight.w700)),
                  Text(VisitDetailHelpers.dateTime(payment.paymentDate),
                      style: AppTheme.font(
                          color: AppTheme.textSecondary, fontSize: AppTheme.textCaption)),
                ],
              ),
            ),
            Text(
                '${refund ? '-' : '+'}'
                '${VisitDetailHelpers.money(amount.abs(), invoice?.currency)}',
                style: AppTheme.font(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.textSmall,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 18, color: AppTheme.iconGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: AppTheme.font(color: AppTheme.textSecondary, fontSize: AppTheme.textBody)),
          ),
        ],
      ),
    );
  }
}
