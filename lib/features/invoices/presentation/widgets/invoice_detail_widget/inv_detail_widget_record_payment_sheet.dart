import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_bottom_sheet.dart';
import 'package:visit_proof/features/invoices/domain/usecases/record_payment_uc.dart';
import 'package:visit_proof/features/invoices/presentation/controller/invoices_bloc.dart';

import '../../../../../core/services/services_locator.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../core/utils/enums/payment_method_enum.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';

class InvDetailWidgetRecordPaymentSheet extends StatefulWidget {
  const InvDetailWidgetRecordPaymentSheet(
      {super.key,
      this.validator,
      required this.invoiceID,
      required this.subtitle});
  final String invoiceID;
  final String subtitle;
  final String? Function(String? v)? validator;

  @override
  State<InvDetailWidgetRecordPaymentSheet> createState() =>
      _InvDetailWidgetRecordPaymentSheetState();
}

class _InvDetailWidgetRecordPaymentSheetState
    extends State<InvDetailWidgetRecordPaymentSheet> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InvoicesBloc>(),
      child: BlocConsumer<InvoicesBloc, InvoicesState>(
        listener: (context, state) {
          if (state.invoiceDetailRequestState == RequestState.loaded) {
            Navigator.pop(context, true);
          }
        },
        listenWhen: (previous, current) =>
            previous.invoiceDetailRequestState !=
            current.invoiceDetailRequestState,
        builder: (context, state) {
          return GWidgetBottomSheet(
            title: 'Record a payment',
            subtitle: widget.subtitle,
            body: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GWidgetTextField(
                      controller: _amount,
                      labelText: 'Amount',
                      hintText: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: widget.validator),
                  const SizedBox(height: 13),
                  GWidgetDropDown<PaymentMethod>(
                    labelText: 'Payment method',
                    value: _method,
                    items: PaymentMethod.values.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(
                          PaymentMethodSwitch(
                            paymentMethodEnum: m,
                          ).getText(),
                        ),
                      );
                    }).toList(),
                    onChanged: (m) {
                      if (m != null) {
                        setState(() {
                          _method = m;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 13),
                  GWidgetTextField(
                    controller: _reference,
                    labelText: 'Transaction reference',
                    hintText: _method == PaymentMethod.cash
                        ? 'Optional for cash'
                        : 'Required',
                    validator: (v) => _method != PaymentMethod.cash &&
                            (v?.trim().isEmpty ?? true)
                        ? 'Reference is required'
                        : null,
                  ),
                  const SizedBox(height: 13),
                  GWidgetTextField(
                    controller: _notes,
                    labelText: 'Notes',
                    maxLines: 2,
                    validator: (v) => _method == PaymentMethod.other &&
                            (v?.trim().isEmpty ?? true)
                        ? 'Explain other payment method'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  GWidgetButton(
                    text: 'Save payment',
                    isLoading:
                        state.invoiceDetailRequestState == RequestState.loading,
                    fontSize: AppTheme.textSubtitle,
                    onPressed: () async {
                      if (_form.currentState?.validate() != true) {
                        return;
                      }

                      context.read<InvoicesBloc>().add(RecordPaymentEvent(
                              recordPaymentParameters: RecordPaymentParameters(
                            invoiceId: widget.invoiceID,
                            amount: double.parse(_amount.text.trim()),
                            paymentMethod: _method,
                            referenceNumber: _reference.text.trim(),
                            notes: _notes.text.trim(),
                          )));
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
