import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/usecase/base_use_case.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../../core/utils/general_widgets/g_widget_empty.dart';
import '../../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../data/models/invoice_detail_model.dart';
import '../../../domain/usecases/get_payments_uc.dart';
import '../../controller/invoices_bloc.dart';
import '../../screens/invoice_detail_scr.dart';
import '../payments_widgets/payments_widget_review.dart';
import '../payments_widgets/payments_widget_tile.dart';

/// Every pending field collection, so the admin can confirm them in one
/// sitting instead of opening each invoice.
class CollectionsBody extends StatelessWidget {
  const CollectionsBody({super.key});

  void _refresh(BuildContext context) => context.read<InvoicesBloc>()
    ..add(GetInvoicesEvent(noParameters: NoParameters()))
    ..add(const GetPaymentsEvent(
        getPaymentsParameters: GetPaymentsParameters(pendingOnly: true)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: GWidgetAppbar(
              title: 'Collections'.tr, )
          .appbar(),
      body: BlocBuilder<InvoicesBloc, InvoicesState>(
        builder: (context, state) {
          final invoices = {
            for (final invoice in state.invoices) invoice.id: invoice
          };
          final payments = state.payments.where((e) => e.isPending).toList();
          final total = payments.fold<num>(
              0, (sum, payment) => sum + (payment.paymentAmount ?? 0));
          final loading = state.paymentsRequestState == RequestState.loading &&
              payments.isEmpty;

          return GWidgetLoading(
            isLoading: loading,
            body: RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () async => _refresh(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  if (payments.isNotEmpty) ...[
                    GTourTarget(id: 'summary', child: _Summary(count: payments.length, total: total)),
                    const SizedBox(height: 14),
                  ],
                  if (payments.isEmpty && !loading)
                    GWidgetEmpty(
                      icon: Icons.task_alt_rounded,
                      title: 'Nothing to confirm'.tr,
                      subtitle:
                          'Payments technicians collect on site appear here until you confirm them.'
                              .tr,
                    ),
                  for (final payment in payments) ...[
                    GTourTarget(id: 'tile_${payments.indexOf(payment)}', child: PaymentsWidgetTile(
                      payment: payment,
                      currency: invoices[payment.invoiceId]?.currency,
                      title: _title(invoices[payment.invoiceId]),
                      reviewing: state.reviewPaymentRequestState ==
                          RequestState.loading,
                      onTap: () async {
                        await Navigator.pushNamed(
                            context, InvoiceDetailScr.route,
                            arguments:
                                InvoiceDetailArgu(invoiceID: payment.invoiceId!)
                                    .toArgu());
                        if (context.mounted) _refresh(context);
                      },
                      onConfirm: () => PaymentsWidgetReview.confirm(
                          context, payment,
                          currency: invoices[payment.invoiceId]?.currency),
                      onReject: () =>
                          PaymentsWidgetReview.reject(context, payment),
                    )),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _title(InvoiceDetailModel? invoice) {
    if (invoice == null) return null;
    return [
      if ((invoice.invoiceNumber ?? '').isNotEmpty) invoice.invoiceNumber!,
      if ((invoice.visitNumber ?? '').isNotEmpty) invoice.visitNumber!,
      if ((invoice.client?.name ?? '').isNotEmpty) invoice.client!.name!,
    ].join(' · ');
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.count, required this.total});
  final int count;
  final num total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.pending,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Awaiting your confirmation'.tr,
              style: AppTheme.font(
                  color: AppTheme.onPrimary,
                  fontSize: AppTheme.textSmall,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(VisitDetailHelpers.money(total),
              style: AppTheme.font(
                  color: AppTheme.onPrimary,
                  fontSize: AppTheme.textDisplay,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('{0} collections from technicians'.trArgs([count]),
              style: AppTheme.font(
                  color: AppTheme.onPrimary, fontSize: AppTheme.textSmall)),
        ],
      ),
    );
  }
}
