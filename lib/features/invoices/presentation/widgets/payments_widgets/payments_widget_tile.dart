import 'package:visit_proof/core/utils/general_widgets/g_widget_local_image.dart';
import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/enums/payment_entry_status_enum.dart';
import '../../../../../core/utils/enums/payment_method_enum.dart';
import '../../../../../core/utils/general_widgets/g_widget_location_view_scr.dart';
import '../../../../../core/utils/general_widgets/g_widget_photo_viewer.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../data/models/invoice_payment_history_model.dart';

/// One ledger entry: the amount, who collected it and how, and for a field
/// collection the technician's location and receipt photos.
///
/// [onConfirm] / [onReject] show the admin's review buttons on a pending
/// entry; [title] (e.g. the invoice and visit) goes above the amount.
class PaymentsWidgetTile extends StatelessWidget {
  const PaymentsWidgetTile({
    super.key,
    required this.payment,
    this.currency,
    this.title,
    this.onTap,
    this.onConfirm,
    this.onReject,
    this.reviewing = false,
  });

  final InvoicePaymentHistoryModel payment;
  final String? currency;
  final String? title;
  final VoidCallback? onTap;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final bool reviewing;

  @override
  Widget build(BuildContext context) {
    final status =
        PaymentEntryStatusSwitch(paymentEntryStatusEnum: payment.entryStatus);
    final amount = payment.paymentAmount ?? 0;
    final refund = amount < 0;
    final photos = payment.photos ?? const <String>[];
    final location = payment.location;
    final reference = (payment.referenceNumber ?? '').trim();
    final notes = (payment.notes ?? '').trim();
    final reviewNote = (payment.reviewNote ?? '').trim();
    final collector = (payment.collectedBy?.name ?? '').trim();

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: payment.isPending
                    ? status.getColor().withValues(alpha: .6)
                    : AppTheme.iconLightGrey.withValues(alpha: .5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if ((title ?? '').isNotEmpty) ...[
                Text(title!,
                    style: AppTheme.font(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.textSmall,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                        refund
                            ? 'Refund {0}'.trArgs([
                                VisitDetailHelpers.money(-amount, currency)
                              ])
                            : VisitDetailHelpers.money(amount, currency),
                        style: AppTheme.font(
                            color: refund
                                ? AppTheme.statOrange
                                : AppTheme.textPrimary,
                            fontSize: AppTheme.textTitle,
                            fontWeight: FontWeight.w800)),
                  ),
                  _Pill(text: status.getText(), color: status.getColor()),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                  [
                    if (!refund && payment.paymentMethod != null)
                      PaymentMethodSwitch(
                              paymentMethodEnum: payment.paymentMethod)
                          .getText(),
                    VisitDetailHelpers.dateTime(payment.paymentDate),
                    if (collector.isNotEmpty) collector,
                  ].join(' · '),
                  style: AppTheme.font(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.textSmall)),
              if (reference.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Reference: {0}'.trArgs([reference]),
                    style: AppTheme.font(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.textSmall)),
              ],
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(notes,
                    style: AppTheme.font(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.textSmall,
                        height: 1.4)),
              ],
              if (location != null && location.isValid) ...[
                const SizedBox(height: 8),
                _LocationChip(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GWidgetLocationViewScr(
                          latitude: location.latitude!,
                          longitude: location.longitude!),
                    ),
                  ),
                ),
              ],
              if (photos.isNotEmpty) ...[
                const SizedBox(height: 10),
                _Photos(paths: photos),
              ],
              if (reviewNote.isNotEmpty || payment.reviewedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                    [
                      '{0} by {1}'.trArgs([
                        status.getText(),
                        payment.reviewedBy?.name ?? 'Admin'.tr
                      ]),
                      VisitDetailHelpers.dateTime(payment.reviewedAt),
                      if (reviewNote.isNotEmpty) reviewNote,
                    ].join(' · '),
                    style: AppTheme.font(
                        color: status.getColor(),
                        fontSize: AppTheme.textSmall,
                        fontWeight: FontWeight.w600)),
              ],
              if (payment.isPending &&
                  (onConfirm != null || onReject != null)) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: reviewing ? null : onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.statOrange,
                          side: BorderSide(color: AppTheme.statOrange),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: Text('Reject'.tr,
                            style: AppTheme.font(
                                color: AppTheme.statOrange,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: reviewing ? null : onConfirm,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.statGreen,
                          foregroundColor: AppTheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text('Confirm'.tr,
                            style: AppTheme.font(
                                color: AppTheme.onPrimary,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text,
          style: AppTheme.font(
              color: color,
              fontSize: AppTheme.textCaption,
              fontWeight: FontWeight.w800)),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.primary;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Material(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_rounded, size: 14, color: color),
                const SizedBox(width: 4),
                Text('Where it was collected'.tr,
                    style: AppTheme.font(
                        color: color,
                        fontSize: AppTheme.textCaption,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Photos extends StatelessWidget {
  const _Photos({required this.paths});
  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => GWidgetPhotoViewer.open(
              context,
              [
                for (final path in paths)
                  GWidgetPhotoItem(path: path, caption: 'Payment receipt'.tr)
              ],
              initialIndex: index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GWidgetLocalImage(
              path: paths[index],
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 64,
                height: 64,
                color: AppTheme.iconLightGrey.withValues(alpha: .3),
                child: Icon(Icons.broken_image_outlined,
                    color: AppTheme.iconGrey),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
