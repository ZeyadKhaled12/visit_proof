import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../visit_detail/domain/rules/visit_rules.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../data/models/invoice_payment_history_model.dart';
import '../../../domain/usecases/review_payment_uc.dart';
import '../../controller/invoices_bloc.dart';

/// The admin's decision on a field collection. Both actions ask first and
/// then send a [ReviewPaymentEvent] to the [InvoicesBloc] above [context].
class PaymentsWidgetReview {
  PaymentsWidgetReview._();

  static Future<void> confirm(
    BuildContext context,
    InvoicePaymentHistoryModel payment, {
    String? currency,
  }) async {
    final bloc = context.read<InvoicesBloc>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Confirm this collection?'.tr,
            style: AppTheme.font(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w800)),
        content: Text(
            '{0} will be added to the paid amount of the invoice.'.trArgs(
                [VisitDetailHelpers.money(payment.paymentAmount, currency)]),
            style: AppTheme.font(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.textBodyLarge)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Back'.tr,
                style: AppTheme.font(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirm'.tr,
                style: AppTheme.font(
                    color: AppTheme.statGreen, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    bloc.add(ReviewPaymentEvent(
        reviewPaymentParameters: ReviewPaymentParameters(
            invoiceId: payment.invoiceId!,
            paymentId: payment.id!,
            approve: true)));
  }

  static Future<void> reject(
    BuildContext context,
    InvoicePaymentHistoryModel payment,
  ) async {
    final bloc = context.read<InvoicesBloc>();
    final reason = await showDialog<String>(
        context: context, builder: (_) => const _RejectDialog());
    if (reason == null) return;
    bloc.add(ReviewPaymentEvent(
        reviewPaymentParameters: ReviewPaymentParameters(
            invoiceId: payment.invoiceId!,
            paymentId: payment.id!,
            approve: false,
            note: reason)));
  }
}

class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  bool get _valid => _reason.text.trim().length >= VisitRules.minReasonLength;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      title: Text('Reject this collection?'.tr,
          style: AppTheme.font(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
              'The amount stays unpaid on the invoice. Tell the technician why.'
                  .tr,
              style: AppTheme.font(
                  color: AppTheme.textSecondary, fontSize: AppTheme.textBody)),
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            maxLines: 3,
            maxLength: 1000,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: AppTheme.font(
                color: AppTheme.textPrimary, fontSize: AppTheme.textBody),
            decoration: InputDecoration(
              hintText: 'Reason (at least {0} characters)'
                  .trArgs([VisitRules.minReasonLength]),
              hintStyle: AppTheme.font(
                  color: AppTheme.textLightHint, fontSize: AppTheme.textBody),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Back'.tr,
              style: AppTheme.font(color: AppTheme.textSecondary)),
        ),
        TextButton(
          onPressed:
              _valid ? () => Navigator.pop(context, _reason.text.trim()) : null,
          child: Text('Reject'.tr,
              style: AppTheme.font(
                  color: _valid ? AppTheme.statOrange : AppTheme.textLightHint,
                  fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
