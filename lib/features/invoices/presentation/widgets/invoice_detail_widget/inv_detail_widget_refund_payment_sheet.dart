import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_bottom_sheet.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../core/services/services_locator.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../domain/usecases/refund_payment_uc.dart';
import '../../controller/invoices_bloc.dart';

class InvDetailWidgetRefundPaymentSheet extends StatefulWidget {
  const InvDetailWidgetRefundPaymentSheet(
      {super.key, this.validator, required this.invoiceID});
  final String? Function(String? v)? validator;
  final String invoiceID;

  @override
  State<InvDetailWidgetRefundPaymentSheet> createState() =>
      _InvDetailWidgetRefundPaymentSheetState();
}

class _InvDetailWidgetRefundPaymentSheetState
    extends State<InvDetailWidgetRefundPaymentSheet> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InvoicesBloc>(),
      child: BlocConsumer<InvoicesBloc, InvoicesState>(
        listener: (context, state) {
          if (state.invoiceDetailRequestState == RequestState.loaded) {
            Navigator.pop(context);
          }
        },
        listenWhen: (previous, current) =>
            previous.invoiceDetailRequestState !=
            current.invoiceDetailRequestState,
        builder: (context, state) {
          return GWidgetBottomSheet(
              title: 'Refund payment',
              subtitle: 'Refunds require a verified payment ledger.',
              body: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GWidgetTextField(
                        controller: _amount,
                        labelText: 'Refund amount',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: widget.validator),
                    const SizedBox(height: 13),
                    GWidgetTextField(
                      controller: _reason,
                      labelText: 'Reason',
                      maxLines: 3,
                      validator: (v) => (v?.trim().length ?? 0) < 8
                          ? 'Enter at least 8 characters'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    GWidgetButton(
                      text: 'Confirm refund',
                      fontSize: 15,
                      isLoading: state.invoiceDetailRequestState ==
                          RequestState.loading,
                      backgroundColor: AppColors.statOrange,
                      onPressed: () async {
                        if (_form.currentState?.validate() != true) {
                          return;
                        }
                        context.read<InvoicesBloc>().add(RefundPaymentEvent(
                                refundPaymentParameters:
                                    RefundPaymentParameters(
                              invoiceId: widget.invoiceID,
                              amount: double.parse(_amount.text.trim()),
                              reason: _reason.text.trim(),
                            )));
                      },
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }
}
