import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/features/invoices/data/models/invoice_detail_model.dart';
import 'package:visit_proof/features/invoices/domain/usecases/update_draft_invoice_uc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/services/services_locator.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../core/utils/general_widgets/g_widget_bottom_sheet.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../controller/invoices_bloc.dart';

class InvDetailWidgetEditSheet extends StatefulWidget {
  const InvDetailWidgetEditSheet(
      {super.key,
      this.validatorDiscount,
      this.validatorTax,
      required this.invoice,
      required this.subtitle});
  final InvoiceDetailModel invoice;
  final String subtitle;
  final String? Function(String? v)? validatorDiscount;
  final String? Function(String? v)? validatorTax;

  @override
  State<InvDetailWidgetEditSheet> createState() =>
      _InvDetailWidgetEditSheetState();
}

class _InvDetailWidgetEditSheetState extends State<InvDetailWidgetEditSheet> {
  final form = GlobalKey<FormState>();

  TextEditingController _discount = TextEditingController();

  TextEditingController _tax = TextEditingController();

  TextEditingController _notes = TextEditingController();

  @override
  void initState() {
    _discount = TextEditingController(
      text: widget.invoice.discountAmount.toString(),
    );
    _tax = TextEditingController(
      text: widget.invoice.taxAmount.toString(),
    );

    _notes = TextEditingController(
      text: widget.invoice.notes ?? '',
    );

    super.initState();
  }

  @override
  void dispose() {
    _discount.dispose();
    _tax.dispose();
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
            title: 'Edit draft invoice',
            subtitle: widget.subtitle,
            body: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GWidgetTextField(
                      controller: _discount,
                      labelText: 'Discount',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: widget.validatorDiscount),
                  const SizedBox(height: 13),
                  GWidgetTextField(
                      controller: _tax,
                      labelText: 'Tax amount',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: widget.validatorTax),
                  const SizedBox(height: 13),
                  GWidgetTextField(
                    controller: _notes,
                    labelText: 'Invoice notes',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  GWidgetButton(
                    text: 'Save changes',
                    fontSize: AppTheme.textSubtitle,
                    isLoading:
                        state.invoiceDetailRequestState == RequestState.loading,
                    onPressed: () async {
                      if (form.currentState?.validate() != true) {
                        return;
                      }

                      final newTotal = widget.invoice.subtotal!.toDouble() -
                          double.parse(_discount.text) +
                          double.parse(_tax.text);

                      if (newTotal < 0 ||
                          newTotal <
                              (widget.invoice.paidAmount?.toDouble() ?? 0)) {
                        AppToasts.showMessage(
                            'New total cannot be negative or below paid amount.',
                            color: AppTheme.primary);
                        return;
                      }
                      context.read<InvoicesBloc>().add(UpdateDraftInvoiceEvent(
                              updateDraftInvoiceParameters:
                                  UpdateDraftInvoiceParameters(
                            invoiceId: widget.invoice.id!,
                            discountAmount: double.parse(_discount.text.trim()),
                            taxAmount: double.parse(_tax.text.trim()),
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
