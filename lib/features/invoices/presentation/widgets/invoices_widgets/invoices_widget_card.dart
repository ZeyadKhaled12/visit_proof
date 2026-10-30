import 'package:flutter/material.dart';

import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/configs/app_fonts.dart';
import 'package:visit_proof/core/utils/enums/payment_status_enum.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/invoices/presentation/screens/invoice_detail_scr.dart';

class InvoicesWidgetCard extends StatelessWidget {
  const InvoicesWidgetCard({super.key, required this.invoice});

  final InvoiceDetailModel invoice;

  // ==========================================================
  // STATUS HELPERS
  // ==========================================================

  bool get _isClosed =>
      invoice.paymentStatus == PaymentStatus.cancelled ||
      invoice.paymentStatus == PaymentStatus.refunded;

  bool get _isDraft => invoice.issueDate == null && !_isClosed;

  bool get _isOverdue {
    if (_isDraft || _isClosed || invoice.dueDate == null) {
      return false;
    }

    if ((invoice.remainingAmount ?? 0) <= 0) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return invoice.dueDate!.isBefore(today);
  }

  String get _statusText {
    if (_isDraft) return 'Draft';

    switch (invoice.paymentStatus) {
      case PaymentStatus.unpaid:
        return 'Unpaid';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.partiallyPaid:
        return 'Partially Paid';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
      case null:
        return 'Unknown';
    }
  }

  Color get _statusColor {
    if (_isDraft) return AppColors.primary;

    switch (invoice.paymentStatus) {
      case PaymentStatus.unpaid:
        return AppColors.statOrange;
      case PaymentStatus.pending:
        return AppColors.pending;
      case PaymentStatus.partiallyPaid:
        return AppColors.primary;
      case PaymentStatus.paid:
        return AppColors.statGreen;
      case PaymentStatus.cancelled:
      case PaymentStatus.refunded:
        return AppColors.textSecondary;
      case null:
        return AppColors.iconGrey;
    }
  }

  // ==========================================================
  // FORMATTING
  // ==========================================================

  String _money(num? amount) {
    if (amount == null || !amount.toDouble().isFinite) {
      return '—';
    }

    return '${amount.toStringAsFixed(2)} '
            '${invoice.currency ?? ''}'
        .trim();
  }

  String _date(DateTime? date) {
    if (date == null) return 'Not set';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  double get _paymentProgress {
    final total = (invoice.totalAmount ?? 0).toDouble();
    final paid = (invoice.paidAmount ?? 0).toDouble();

    if (!total.isFinite || !paid.isFinite || total <= 0 || paid < 0) {
      return 0;
    }

    return (paid / total).clamp(0.0, 1.0).toDouble();
  }

  // ==========================================================
  // SMALL AMOUNT WIDGET
  // ==========================================================

  Widget _amountInfo({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // INVOICE CARD UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            if (invoice.id == null) return;
            await Navigator.pushNamed(context, InvoiceDetailScr.route,
                arguments: InvoiceDetailArgu(invoiceID: invoice.id!).toArgu());
          },
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------
                // INVOICE NUMBER + STATUS
                // --------------------------------------

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.invoiceNumber ?? 'Invoice',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            invoice.visitNumber ?? 'No visit number',
                            style: AppFonts(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        _statusText,
                        style: AppFonts(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --------------------------------------
                // CUSTOMER
                // --------------------------------------

                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.iconGrey,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        invoice.client?.name ?? 'Customer not selected',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Divider(
                  color: AppColors.iconLightGrey.withValues(alpha: .3),
                ),

                const SizedBox(height: 8),

                // --------------------------------------
                // FINANCIAL AMOUNTS
                // --------------------------------------

                Row(
                  children: [
                    Expanded(
                      child: _amountInfo(
                        label: 'Invoice total',
                        value: _money(invoice.totalAmount),
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _amountInfo(
                        label: 'Remaining',
                        value: _money(invoice.remainingAmount),
                        color: (invoice.remainingAmount ?? 0) > 0
                            ? AppColors.primary
                            : AppColors.statGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // --------------------------------------
                // PAYMENT PROGRESS
                // --------------------------------------

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _paymentProgress,
                    minHeight: 6,
                    backgroundColor: AppColors.locationChipBg,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.statGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Paid ${_money(invoice.paidAmount)}',
                  style: AppFonts(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 14),

                // --------------------------------------
                // DATES + DETAILS ARROW
                // --------------------------------------

                Row(
                  children: [
                    Icon(
                      _isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.calendar_today_outlined,
                      size: 15,
                      color: _isOverdue
                          ? AppColors.statOrange
                          : AppColors.iconGrey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _isOverdue
                            ? 'Overdue · ${_date(invoice.dueDate)}'
                            : _isDraft
                                ? 'Created ${_date(invoice.createdAt)}'
                                : 'Due ${_date(invoice.dueDate)}',
                        style: AppFonts(
                          color: _isOverdue
                              ? AppColors.statOrange
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight:
                              _isOverdue ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      'Details',
                      style: AppFonts(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
