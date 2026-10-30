import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/configs/app_fonts.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_appbar.dart';
import '../widgets/invoice_action_policy.dart';
import '../widgets/invoice_display_widgets.dart';

/// Payment ledger and immutable invoice activity. Data supplied by caller.
class AdminInvoiceHistoryScreen extends StatelessWidget {
  const AdminInvoiceHistoryScreen({super.key, required this.snapshot});
  final InvoiceAdminContext snapshot;

  @override
  Widget build(BuildContext context) => !snapshot.adminAuthorized
    ? Scaffold(backgroundColor: AppColors.scaffoldBackground,
        body: const Center(child: InvoiceAlertStrip(
          message: 'Access denied to invoice history.',
          color: AppColors.statOrange)))
    : DefaultTabController(
    length: 3,
    child: Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: GWidgetAppbar(title: 'Invoice History',
        icon: Icons.manage_history_rounded).appbar(),
      body: Column(children: [
        Container(color: AppColors.surfaceWhite,
          child: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            labelStyle: AppFonts(fontSize: 14, fontWeight: FontWeight.w800),
            unselectedLabelStyle: AppFonts(fontSize: 14),
            tabs: const [Tab(text: 'Payments'), Tab(text: 'Activity'),
              Tab(text: 'Adjustments')],
          )),
        Expanded(child: TabBarView(children: [
          _payments(), _activities(), _adjustments(),
        ])),
      ]),
    ),
  );

  Widget _payments() {
    if (!snapshot.paymentLedgerLoaded) {
      return const Center(child: InvoiceAlertStrip(
        message: 'Payment history is not fully loaded.'));
    }
    if (snapshot.payments.isEmpty) return _empty('No payment transactions');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: snapshot.payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final e = snapshot.payments[index];
        return InvoiceSectionCard(
          title: e.payment.referenceNumber?.isNotEmpty == true
            ? e.payment.referenceNumber! : 'Payment #${index + 1}',
          icon: Icons.payments_outlined,
          child: Column(children: [
            InvoicePaymentRow(entry: e,
              currency: snapshot.invoice?.currency),
            InvoiceInfoRow(label: 'Collector',
              value: e.payment.collectedBy?.name ?? '—'),
            InvoiceInfoRow(label: 'Payment notes',
              value: e.payment.notes ?? '—'),
            InvoiceInfoRow(label: 'Payment ID', value: e.id),
          ]),
        );
      },
    );
  }

  Widget _activities() {
    if (snapshot.activities.isEmpty) return _empty('No activity entries');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: snapshot.activities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final entry = snapshot.activities[index];
        return InvoiceSectionCard(title: entry.title,
          icon: Icons.history_toggle_off_rounded,
          child: Column(children: [
            InvoiceInfoRow(label: 'Date',
              value: invoiceDate(entry.occurredAt)),
            InvoiceInfoRow(label: 'By', value: entry.actorName),
            InvoiceInfoRow(label: 'Details', value: entry.detail),
          ]));
      },
    );
  }

  Widget _adjustments() {
    if (!snapshot.adjustmentsLoaded) {
      return const Center(child: InvoiceAlertStrip(
        message: 'Adjustment ledger has not been loaded.'));
    }
    if (snapshot.adjustments.isEmpty) return _empty('No financial adjustments');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: snapshot.adjustments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final a = snapshot.adjustments[index];
        return InvoiceSectionCard(title: a.kind == InvoiceAdjustmentKind.credit
            ? 'Credit adjustment' : 'Debit adjustment',
          icon: Icons.tune_rounded,
          child: Column(children: [
            InvoiceInfoRow(label: 'Amount',
              value: invoiceMoney(a.amount, snapshot.invoice?.currency)),
            InvoiceInfoRow(label: 'Date', value: invoiceDate(a.date)),
            InvoiceInfoRow(label: 'Reason', value: a.reason),
            InvoiceInfoRow(label: 'Reference', value: a.id),
          ]));
      },
    );
  }

  Widget _empty(String title) => Center(child: Text(title,
    style: AppFonts(color: AppColors.textSecondary, fontSize: 15)));
}
