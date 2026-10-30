import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/configs/app_fonts.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_appbar.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';
import 'package:visit_proof/configs/app_toasts.dart';
import '../widgets/invoice_action_policy.dart';
import '../widgets/invoice_action_sheet.dart';
import '../widgets/invoice_display_widgets.dart';
import 'admin_invoice_history_screen.dart';

/// All invoice modifications begin from this screen. Pass a consistent snapshot
/// of the linked visit + invoice + all payment ledger entries.
///
/// [onCommandPrepared] receives validated, ready-to-send data ONLY. This class
/// deliberately does not implement API calls, persistence, or optimistic status
/// updates. Refresh/swap [snapshot] after your own API confirms success.
class AdminInvoiceDetailScreen extends StatelessWidget {
  const AdminInvoiceDetailScreen({super.key, required this.snapshot,
    this.onCommandPrepared, this.onOpenVisit});

  final InvoiceAdminContext snapshot;
  final ValueChanged<InvoiceActionCommand>? onCommandPrepared;
  final ValueChanged<String>? onOpenVisit;

  InvoiceAdminPolicy get policy => InvoiceAdminPolicy(snapshot);

  void _action(BuildContext context, InvoiceAction action,
      {InvoicePaymentEntry? payment}) {
    final check = payment == null
        ? policy.check(action) : policy.checkPayment(action, payment);
    if (!check.allowed) {
      // Existing centralized toast class, not reimplemented.
      AppToasts.showMessage(check.reason, isError: true);
      return;
    }
    if (action == InvoiceAction.viewPaymentHistory) {
      Navigator.push(context, MaterialPageRoute<void>(
        builder: (_) => AdminInvoiceHistoryScreen(snapshot: snapshot)));
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => InvoiceActionSheet(
        action: action,
        snapshot: snapshot,
        initialPayment: payment,
        onPrepared: (command) {
          if (onCommandPrepared != null) {
            // TODO API INTEGRATION (outside this screen):
            // 1) Revalidate link, permissions, amount, ledger, and expected version.
            // 2) Send command.data to the action-specific endpoint.
            // 3) After API success: refetch InvoiceDetailModel, VisitDetailModel,
            //    invoice stage, payment entries and activity/adjustment ledger.
            // 4) After API failure: show backend errors, no local state mutation.
            onCommandPrepared!(command);
          } else {
            AppToasts.showMessage('Valid request prepared; API is not connected yet.');
          }
        },
      ),
    );
  }

  Future<void> _showPaymentActions(BuildContext context, InvoicePaymentEntry entry) {
    final choices = [InvoiceAction.confirmPayment,
      InvoiceAction.reversePayment, InvoiceAction.refundPayment];
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(padding: const EdgeInsets.all(19),
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Payment actions', style: AppFonts(
                color: AppColors.textPrimary, fontSize: 18,
                fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...choices.map((action) {
                final decision = policy.checkPayment(action, entry);
                return Padding(padding: const EdgeInsets.only(bottom: 9),
                  child: InvoiceActionTile(action: action, decision: decision,
                    onTap: () {
                      if (!decision.allowed) {
                        AppToasts.showMessage(decision.reason, isError: true);
                        return;
                      }
                      Navigator.pop(sheetContext);
                      _action(context, action, payment: entry);
                    }),
                );
              }),
            ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!snapshot.adminAuthorized) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: GWidgetAppbar(title: 'Invoice Details',
          icon: Icons.lock_outline_rounded).appbar(),
        body: const Center(child: Padding(
          padding: EdgeInsets.all(20),
          child: InvoiceAlertStrip(color: AppColors.statOrange,
            message: 'You do not have permission to manage invoices.'),
        )),
      );
    }
    final i = snapshot.invoice;
    final v = snapshot.visit;
    final document = policy.documentHealth;
    final ledger = policy.ledgerHealth;
    final allActions = i == null
        ? [InvoiceAction.create]
        : [
            InvoiceAction.editAmounts,
            InvoiceAction.issue,
            InvoiceAction.recordPayment,
            InvoiceAction.confirmPayment,
            InvoiceAction.changeDueDate,
            InvoiceAction.adjustBalance,
            InvoiceAction.refundPayment,
            InvoiceAction.reversePayment,
            InvoiceAction.cancelInvoice,
            InvoiceAction.addNote,
            InvoiceAction.downloadPdf,
            InvoiceAction.sendEmail,
            InvoiceAction.sendWhatsApp,
            InvoiceAction.viewPaymentHistory,
          ];
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: GWidgetAppbar(title: 'Invoice Details',
        icon: Icons.receipt_long_rounded).appbar(),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, viewport) =>
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (i != null) InvoiceBalanceHero(policy: policy),
                  if (i == null) const InvoiceAlertStrip(
                    message: 'This Visit has no invoice yet. Create the single linked Draft invoice.'),
                  const SizedBox(height: 15),
                  Wrap(spacing: 7, runSpacing: 7, children: [
                    InvoiceStatusChip(label: 'Visit: ${visitStatusLabel(v.status)}',
                      color: AppColors.primary,
                      icon: Icons.location_on_outlined),
                    if (i != null) ...[
                      InvoiceStatusChip(
                        label: 'Invoice: ${invoiceDocumentLabel(snapshot.documentState)}',
                        color: invoiceDocumentColor(snapshot.documentState)),
                      InvoiceStatusChip(label: 'Payment: ${i.paymentStatus == null ? 'Unknown' : i.paymentStatus!.name}',
                        color: i.remainingAmount == 0
                          ? AppColors.statGreen : AppColors.pending),
                    ],
                  ]),
                  const SizedBox(height: 15),
                  if (!document.allowed && i != null) ...[
                    InvoiceAlertStrip(message: document.reason,
                        color: AppColors.statOrange),
                    const SizedBox(height: 12),
                  ],
                  if (i != null && !ledger.allowed) ...[
                    InvoiceAlertStrip(message: 'Payment validation: ${ledger.reason}. Financial actions will be locked.',
                        color: AppColors.pending),
                    const SizedBox(height: 12),
                  ],
                  if (i != null && snapshot.documentState == InvoiceDocumentState.issued &&
                      v.status != null && v.status != VisitStatus.completed) ...[
                    const InvoiceAlertStrip(message:
                      'Issued invoice + active/reopened Visit: edit the Visit evidence separately. Use adjustments for financial corrections.'),
                    const SizedBox(height: 12),
                  ],
                  InvoiceSectionCard(title: 'Linked service visit',
                    icon: Icons.home_repair_service_rounded,
                    trailing: onOpenVisit == null || v.id == null
                        ? null : TextButton.icon(
                            onPressed: () => onOpenVisit!(v.id!),
                            icon: const Icon(Icons.open_in_new_rounded, size: 16,
                              color: AppColors.primary),
                            label: Text('Open Visit', style: AppFonts(
                              color: AppColors.primary, fontSize: 12,
                              fontWeight: FontWeight.w700))),
                    child: Column(children: [
                      InvoiceInfoRow(label: 'Visit #', value: v.visitNumber ?? '—'),
                      InvoiceInfoRow(label: 'Service', value: v.serviceName ?? '—'),
                      InvoiceInfoRow(label: 'Client',
                        value: v.client?.name ?? i?.client?.name ?? '—'),
                      InvoiceInfoRow(label: 'Location',
                        value: v.site?.addressDetail ?? i?.site?.addressDetail ?? '—'),
                      InvoiceInfoRow(label: 'Scheduled', value: invoiceDate(v.startDate)),
                      InvoiceInfoRow(label: 'Service price',
                        value: invoiceMoney(v.price, i?.currency)),
                    ])),
                  if (i != null) ...[
                    const SizedBox(height: 15),
                    InvoiceSectionCard(title: 'Invoice breakdown',
                      icon: Icons.calculate_outlined,
                      child: Column(children: [
                        InvoiceInfoRow(label: 'Subtotal',
                          value: invoiceMoney(i.subtotal, i.currency)),
                        InvoiceInfoRow(label: 'Discount',
                          value: '- ${invoiceMoney(i.discountAmount, i.currency)}',
                          valueColor: AppColors.statOrange),
                        InvoiceInfoRow(label: 'Tax',
                          value: invoiceMoney(i.taxAmount, i.currency)),
                        Divider(color: AppColors.iconLightGrey.withValues(alpha: .28)),
                        InvoiceInfoRow(label: 'Original total',
                          value: invoiceMoney(i.totalAmount, i.currency),
                          emphasize: true, valueColor: AppColors.primary),
                        if (snapshot.adjustments.isNotEmpty)
                          InvoiceInfoRow(label: 'Net adjustments',
                            value: invoiceMoney(policy.effectiveTotal - policy.total, i.currency),
                            valueColor: AppColors.pending),
                        InvoiceInfoRow(label: 'Adjusted total',
                          value: invoiceMoney(policy.effectiveTotal, i.currency),
                          emphasize: true),
                        InvoiceInfoRow(label: 'Paid',
                          value: invoiceMoney(i.paidAmount, i.currency),
                          valueColor: AppColors.statGreen),
                        InvoiceInfoRow(label: 'Remaining',
                          value: invoiceMoney(i.remainingAmount, i.currency),
                          emphasize: true, valueColor: AppColors.statOrange),
                        Divider(color: AppColors.iconLightGrey.withValues(alpha: .28)),
                        InvoiceInfoRow(label: 'Created', value: invoiceDate(i.createdAt)),
                        InvoiceInfoRow(label: 'Issued', value: invoiceDate(i.issueDate)),
                        InvoiceInfoRow(label: 'Due', value: invoiceDate(i.dueDate)),
                        if (i.notes?.trim().isNotEmpty == true)
                          InvoiceInfoRow(label: 'Original notes', value: i.notes!),
                      ])),
                  ],
                  const SizedBox(height: 15),
                  InvoiceSectionCard(title: 'Admin action center',
                    icon: Icons.dashboard_customize_outlined,
                    child: LayoutBuilder(builder: (_, c) {
                      const gap = 9.0;
                      final columns = c.maxWidth > 660 ? 3 : 2;
                      final itemWidth = (c.maxWidth - (columns - 1) * gap) / columns;
                      return Wrap(spacing: gap, runSpacing: gap,
                        children: allActions.map((a) => SizedBox(
                          width: itemWidth, height: 100,
                          child: InvoiceActionTile(
                            action: a,
                            decision: policy.check(a),
                            onTap: () => _action(context, a)),
                        )).toList());
                    })),
                  if (i != null) ...[
                    const SizedBox(height: 15),
                    InvoiceSectionCard(title: 'Recent payment records',
                      icon: Icons.account_balance_wallet_outlined,
                      trailing: TextButton(onPressed: () => _action(
                          context, InvoiceAction.viewPaymentHistory),
                        child: Text('See all', style: AppFonts(
                          color: AppColors.primary, fontWeight: FontWeight.w700))),
                      child: snapshot.payments.isEmpty
                        ? Text(snapshot.paymentLedgerLoaded
                            ? 'No payments recorded yet.'
                            : 'Loading or missing payment ledger.',
                            style: AppFonts(color: AppColors.textSecondary,
                              fontSize: 13))
                        : Column(children: snapshot.payments.take(4).map((e) =>
                            InvoicePaymentRow(entry: e,
                              currency: i.currency,
                              onTap: () => _showPaymentActions(context, e)))
                            .toList()),
                    ),
                    const SizedBox(height: 15),
                    InvoiceSectionCard(title: 'Recent activity',
                      icon: Icons.history_rounded,
                      child: snapshot.activities.isEmpty
                        ? Text('No invoice activity loaded.',
                            style: AppFonts(color: AppColors.textSecondary))
                        : Column(children: snapshot.activities.take(3).map((event) =>
                            InvoiceInfoRow(
                              label: '${invoiceDate(event.occurredAt)} • ${event.actorName}',
                              value: '${event.title}: ${event.detail}'))
                            .toList()),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (i != null && snapshot.documentState == InvoiceDocumentState.issued &&
                      policy.check(InvoiceAction.recordPayment).allowed)
                    GWidgetButton(
                      text: 'Record a payment',
                      colorText: AppColors.surfaceWhite,
                      fontSize: 15, height: 52,
                      backgroundColor: AppColors.secondary,
                      onPressed: () => _action(context, InvoiceAction.recordPayment)),
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}
