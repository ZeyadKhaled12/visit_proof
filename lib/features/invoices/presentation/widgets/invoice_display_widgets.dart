import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/configs/app_fonts.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'invoice_action_policy.dart';

String invoiceMoney(num? value, String? currency) {
  final fixed = (value ?? 0).toDouble().toStringAsFixed(2);
  return '$fixed ${currency?.isNotEmpty == true ? currency : ''}'.trim();
}

String invoiceDate(DateTime? d) => d == null
    ? '—'
    : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String invoiceDocumentLabel(InvoiceDocumentState? value) {
  switch (value) {
    case InvoiceDocumentState.draft:
      return 'Draft';
    case InvoiceDocumentState.issued:
      return 'Issued';
    case InvoiceDocumentState.cancelled:
      return 'Cancelled';
    case null:
      return 'Not created';
  }
}

Color invoiceDocumentColor(InvoiceDocumentState? value) {
  switch (value) {
    case InvoiceDocumentState.draft:
      return AppColors.iconGrey;
    case InvoiceDocumentState.issued:
      return AppColors.statGreen;
    case InvoiceDocumentState.cancelled:
      return AppColors.statOrange;
    case null:
      return AppColors.textSecondary;
  }
}

String invoiceActionTitle(InvoiceAction value) {
  switch (value) {
    case InvoiceAction.create: return 'Create invoice';
    case InvoiceAction.editAmounts: return 'Edit amounts';
    case InvoiceAction.issue: return 'Issue invoice';
    case InvoiceAction.changeDueDate: return 'Change due date';
    case InvoiceAction.recordPayment: return 'Record payment';
    case InvoiceAction.confirmPayment: return 'Confirm payment';
    case InvoiceAction.reversePayment: return 'Reverse payment';
    case InvoiceAction.refundPayment: return 'Refund payment';
    case InvoiceAction.adjustBalance: return 'Financial adjustment';
    case InvoiceAction.cancelInvoice: return 'Cancel invoice';
    case InvoiceAction.addNote: return 'Add note';
    case InvoiceAction.downloadPdf: return 'Download PDF';
    case InvoiceAction.sendEmail: return 'Send by email';
    case InvoiceAction.sendWhatsApp: return 'Send via WhatsApp';
    case InvoiceAction.viewPaymentHistory: return 'Payment history';
  }
}

IconData invoiceActionIcon(InvoiceAction value) {
  switch (value) {
    case InvoiceAction.create: return Icons.note_add_rounded;
    case InvoiceAction.editAmounts: return Icons.edit_note_rounded;
    case InvoiceAction.issue: return Icons.verified_rounded;
    case InvoiceAction.changeDueDate: return Icons.event_repeat_rounded;
    case InvoiceAction.recordPayment: return Icons.add_card_rounded;
    case InvoiceAction.confirmPayment: return Icons.check_circle_outline_rounded;
    case InvoiceAction.reversePayment: return Icons.undo_rounded;
    case InvoiceAction.refundPayment: return Icons.currency_exchange_rounded;
    case InvoiceAction.adjustBalance: return Icons.tune_rounded;
    case InvoiceAction.cancelInvoice: return Icons.block_rounded;
    case InvoiceAction.addNote: return Icons.sticky_note_2_outlined;
    case InvoiceAction.downloadPdf: return Icons.picture_as_pdf_rounded;
    case InvoiceAction.sendEmail: return Icons.forward_to_inbox_rounded;
    case InvoiceAction.sendWhatsApp: return Icons.message_rounded;
    case InvoiceAction.viewPaymentHistory: return Icons.receipt_long_rounded;
  }
}

Color invoiceActionColor(InvoiceAction value) {
  switch (value) {
    case InvoiceAction.issue:
    case InvoiceAction.confirmPayment:
      return AppColors.statGreen;
    case InvoiceAction.cancelInvoice:
    case InvoiceAction.reversePayment:
    case InvoiceAction.refundPayment:
      return AppColors.statOrange;
    case InvoiceAction.recordPayment:
    case InvoiceAction.sendWhatsApp:
      return AppColors.secondary;
    case InvoiceAction.changeDueDate:
    case InvoiceAction.adjustBalance:
      return AppColors.pending;
    default:
      return AppColors.primary;
  }
}

class InvoiceSectionCard extends StatelessWidget {
  const InvoiceSectionCard({super.key, required this.title, required this.child,
    this.icon, this.trailing});
  final String title;
  final IconData? icon;
  final Widget child;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surfaceWhite,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [BoxShadow(color: AppColors.cardShadowColor,
          blurRadius: 18, offset: const Offset(0, 6))],
      border: Border.all(color: AppColors.primary.withValues(alpha: .07)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        if (icon != null) ...[
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 9),
        ],
        Expanded(child: Text(title, style: AppFonts(
          fontWeight: FontWeight.w800, fontSize: 16,
          color: AppColors.textPrimary))),
        if (trailing != null) trailing!,
      ]),
      const SizedBox(height: 14),
      child,
    ]),
  );
}

class InvoiceStatusChip extends StatelessWidget {
  const InvoiceStatusChip({super.key, required this.label, required this.color,
    this.icon});
  final String label;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(30)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[
        Icon(icon, color: color, size: 14), const SizedBox(width: 5),
      ],
      Text(label, style: AppFonts(color: color, fontSize: 12,
          fontWeight: FontWeight.w800)),
    ]),
  );
}

class InvoiceInfoRow extends StatelessWidget {
  const InvoiceInfoRow({super.key, required this.label, required this.value,
    this.emphasize = false, this.valueColor});
  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Text(label, style: AppFonts(color: AppColors.textSecondary,
          fontSize: 13, fontWeight: FontWeight.w500))),
      const SizedBox(width: 12),
      Flexible(flex: 2, child: Text(value, textAlign: TextAlign.end,
        style: AppFonts(color: valueColor ?? AppColors.textPrimary,
          fontSize: emphasize ? 16 : 13,
          fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600))),
    ]),
  );
}

class InvoiceActionTile extends StatelessWidget {
  const InvoiceActionTile({super.key, required this.action, required this.decision,
    required this.onTap});
  final InvoiceAction action;
  final InvoiceDecision decision;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final tone = invoiceActionColor(action);
    return Tooltip(
      message: decision.allowed ? invoiceActionTitle(action) : decision.reason,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: decision.allowed
                ? tone.withValues(alpha: .065)
                : AppColors.scaffoldBackground,
            border: Border.all(color: decision.allowed
                ? tone.withValues(alpha: .20)
                : AppColors.iconLightGrey.withValues(alpha: .24)),
          ),
          child: Row(children: [
            Icon(invoiceActionIcon(action), size: 23,
              color: decision.allowed ? tone : AppColors.iconLightGrey),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, children: [
                Text(invoiceActionTitle(action), maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts(fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: decision.allowed ? AppColors.textPrimary : AppColors.textSecondary)),
                if (!decision.allowed) ...[
                  const SizedBox(height: 3),
                  Text(decision.reason, maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts(fontSize: 10,
                      color: AppColors.textSecondary)),
                ],
              ])),
            Icon(decision.allowed ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
              size: 17,
              color: decision.allowed ? tone : AppColors.iconLightGrey),
          ]),
        ),
      ),
    );
  }
}

class InvoiceBalanceHero extends StatelessWidget {
  const InvoiceBalanceHero({super.key, required this.policy});
  final InvoiceAdminPolicy policy;
  @override
  Widget build(BuildContext context) {
    final i = policy.invoice;
    final total = policy.effectiveTotal;
    final paid = policy.paid;
    final progress = total <= 0 ? 0.0 : (paid / total).clamp(0.0, 1.0).toDouble();
    final currency = i?.currency;
    final paymentColor = i?.paymentStatus == PaymentStatus.paid
        ? AppColors.statGreen
        : i?.paymentStatus == PaymentStatus.partiallyPaid
            ? AppColors.pending : AppColors.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [AppColors.primary,
          AppColors.primary.withValues(alpha: .85), AppColors.secondary]),
        boxShadow: [BoxShadow(color: AppColors.fabShadowColor.withValues(alpha: .24),
          blurRadius: 20, offset: const Offset(0, 9))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(i?.invoiceNumber ?? 'New invoice',
            style: AppFonts(color: AppColors.surfaceWhite, fontSize: 18,
                fontWeight: FontWeight.w800))),
          InvoiceStatusChip(label: invoiceDocumentLabel(policy.stage),
              color: AppColors.surfaceWhite),
        ]),
        const SizedBox(height: 20),
        Text('Outstanding balance', style: AppFonts(
          color: AppColors.surfaceWhite.withValues(alpha: .85), fontSize: 13)),
        const SizedBox(height: 3),
        Text(invoiceMoney(i?.remainingAmount, currency), style: AppFonts(
          color: AppColors.surfaceWhite, fontSize: 32,
          fontWeight: FontWeight.w800)),
        const SizedBox(height: 19),
        ClipRRect(borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: AppColors.surfaceWhite.withValues(alpha: .22),
            valueColor: AlwaysStoppedAnimation<Color>(
                paymentColor == AppColors.primary ? AppColors.surfaceWhite : paymentColor),
          )),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _heroNumber('Total', invoiceMoney(total, currency))),
          Expanded(child: _heroNumber('Paid', invoiceMoney(paid, currency))),
          Expanded(child: _heroNumber('Pending', invoiceMoney(policy.pendingAmount, currency))),
        ]),
      ]),
    );
  }

  Widget _heroNumber(String title, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppFonts(color: AppColors.surfaceWhite.withValues(alpha: .75),
          fontSize: 11)),
      const SizedBox(height: 4),
      Text(value, style: AppFonts(color: AppColors.surfaceWhite,
          fontSize: 12.5, fontWeight: FontWeight.w800)),
    ]);
}

class InvoiceAlertStrip extends StatelessWidget {
  const InvoiceAlertStrip({super.key, required this.message,
    this.color = AppColors.pending, this.icon = Icons.info_outline_rounded});
  final String message;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: .22))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 19), const SizedBox(width: 9),
      Expanded(child: Text(message, style: AppFonts(fontSize: 12.5,
          height: 1.4, color: AppColors.textPrimary))),
    ]),
  );
}

class InvoicePaymentRow extends StatelessWidget {
  const InvoicePaymentRow({super.key, required this.entry, required this.currency,
    this.onTap});
  final InvoicePaymentEntry entry;
  final String? currency;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final state = entry.state;
    final color = state == InvoicePaymentEntryState.confirmed
        ? AppColors.statGreen : state == InvoicePaymentEntryState.pending
            ? AppColors.pending : AppColors.statOrange;
    final label = state == InvoicePaymentEntryState.confirmed
        ? 'Confirmed' : state == InvoicePaymentEntryState.pending
            ? 'Pending' : 'Reversed';
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.payments_outlined, color: color, size: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(invoiceMoney(entry.amount, currency),
                style: AppFonts(fontSize: 14, color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800)),
              Text('${invoiceDate(entry.payment.paymentDate)} • ${entry.payment.referenceNumber ?? 'No reference'}',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: AppFonts(fontSize: 11, color: AppColors.textSecondary)),
              if (entry.refundedAmount > 0)
                Text('Refunded: ${invoiceMoney(entry.refundedAmount, currency)}',
                  style: AppFonts(fontSize: 11, color: AppColors.statOrange)),
            ])),
          InvoiceStatusChip(label: label, color: color),
          if (onTap != null) const Icon(Icons.chevron_right_rounded,
            color: AppColors.iconGrey),
        ])),
    );
  }
}

String visitStatusLabel(VisitStatus? status) => status == null
    ? 'Unknown' : VisitStatusSwitch(visitStatusEnum: status).getText();
