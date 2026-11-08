import 'package:visit_proof/configs/app_tours.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/utils/enums.dart';
import 'package:visit_proof/features/invoices/domain/usecases/get_invoice_detail_uc.dart';
import 'package:visit_proof/features/invoices/presentation/controller/invoices_bloc.dart';
import 'package:visit_proof/features/invoices/presentation/widgets/invoice_detail_widget/invoice_detail_body.dart';

import '../../../../core/services/services_locator.dart';
import '../../domain/usecases/get_payments_uc.dart';

class InvoiceDetailScr extends StatelessWidget {
  const InvoiceDetailScr({super.key});
  static const route = '/InvoiceDetailScr';

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    InvoiceDetailArgu argu = InvoiceDetailArgu(invoiceID: '');
    if (data != null) {
      argu = InvoiceDetailArgu.fromJson(data);
    }

    return GWidgetTourFlag(tour: AppTours.invoiceDetail, child: BlocProvider(
        create: (context) => sl<InvoicesBloc>()
          ..add(GetInvoiceDetailEvent(
              getInvoiceDetailParameters:
                  GetInvoiceDetailParameters(invoiceId: argu.invoiceID)))
          ..add(GetPaymentsEvent(
              getPaymentsParameters:
                  GetPaymentsParameters(invoiceId: argu.invoiceID))),
        child: BlocBuilder<InvoicesBloc, InvoicesState>(
          builder: (context, state) {
            return InvoiceDetailBody(
                invoice: state.invoiceDetailModel,
                payments: state.payments,
                reviewing:
                    state.reviewPaymentRequestState == RequestState.loading,
                loading:
                    state.invoiceDetailRequestState == RequestState.loading);
          },
        )));
  }
}

class InvoiceDetailArgu {
  final String invoiceID;
  InvoiceDetailArgu({required this.invoiceID});
  Map<String, dynamic> toArgu() => {'invoiceID': invoiceID};
  factory InvoiceDetailArgu.fromJson(Map<String, dynamic> argu) =>
      InvoiceDetailArgu(invoiceID: argu['invoiceID']);
}
