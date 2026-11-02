import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_toasts.dart';
import '../../../../../core/utils/enums/payment_method_enum.dart';
import '../../../../../core/utils/enums/photo_kind_enum.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../../invoices/domain/usecases/record_payment_uc.dart';
import '../../../domain/rules/visit_rules.dart';
import '../../controller/visit_detail_bloc.dart';
import '../visit_detail_helpers.dart';
import '../visit_detail_widget_action_sheet.dart';
import '../visit_detail_widget_field_proof.dart';

/// The technician records money the client paid on site. It is sent with
/// their live location and a receipt photo, and stays pending until the
/// admin confirms it.
class VisitDetailWidgetCollectSheet extends StatefulWidget {
  const VisitDetailWidgetCollectSheet({super.key});

  @override
  State<VisitDetailWidgetCollectSheet> createState() =>
      _VisitDetailWidgetCollectSheetState();
}

class _VisitDetailWidgetCollectSheetState
    extends State<VisitDetailWidgetCollectSheet> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  final _proofKey = GlobalKey<VisitDetailWidgetFieldProofState>();
  VisitFieldProofValue _proof = const VisitFieldProofValue();
  PaymentMethod _method = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    final collectible = VisitRules.collectibleAmount(
        context.read<VisitDetailBloc>().state.linkedInvoice);
    _amount.text = collectible.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _proofReady =>
      _proof.location != null &&
      _proof.consent &&
      _proof.photoPaths.isNotEmpty;

  void _submit(VisitDetailState state) {
    if (_form.currentState?.validate() != true) return;
    if (_proof.isStale) {
      AppToasts.showMessage(
          'Your location was taken a while ago. Updating it, confirm again.'.tr,
          isError: true);
      _proofKey.currentState?.refreshLocation();
      return;
    }
    context.read<VisitDetailBloc>().add(CollectPaymentEvent(
        recordPaymentParameters: RecordPaymentParameters(
            invoiceId: state.invoice.id!,
            amount: double.parse(_amount.text.trim()),
            paymentMethod: _method,
            referenceNumber: _reference.text.trim(),
            notes: _notes.text.trim(),
            location: _proof.location,
            photoPaths: _proof.photoPaths)));
  }

  @override
  Widget build(BuildContext context) {
    return VisitDetailWidgetActionSheet(
      title: 'Collect payment'.tr,
      subtitle:
          'The admin confirms the payment before it counts as paid.'.tr,
      requestState: (state) => state.collectPaymentRequestState,
      builder: (context, state, loading) {
        final max = VisitRules.collectibleAmount(state.linkedInvoice);
        return Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GWidgetTextField(
                controller: _amount,
                labelText: 'Amount'.tr,
                hintText: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => VisitDetailHelpers.moneyError(v, max: max),
              ),
              const SizedBox(height: 4),
              Text(
                  'Left to collect: {0}'.trArgs([
                    VisitDetailHelpers.money(max, state.invoice.currency)
                  ]),
                  style: AppTheme.font(
                      color: AppTheme.textLightHint,
                      fontSize: AppTheme.textCaption)),
              const SizedBox(height: 13),
              GWidgetDropDown<PaymentMethod>(
                labelText: 'Payment method'.tr,
                value: _method,
                items: [
                  for (final method in PaymentMethod.values)
                    DropdownMenuItem(
                      value: method,
                      child: Text(PaymentMethodSwitch(paymentMethodEnum: method)
                          .getText()),
                    ),
                ],
                onChanged: (method) {
                  if (method != null) setState(() => _method = method);
                },
              ),
              const SizedBox(height: 13),
              GWidgetTextField(
                controller: _reference,
                labelText: 'Transaction reference'.tr,
                hintText: _method == PaymentMethod.cash
                    ? 'Optional for cash'.tr
                    : 'Required'.tr,
                validator: (v) => _method != PaymentMethod.cash &&
                        (v?.trim().isEmpty ?? true)
                    ? 'Reference is required'.tr
                    : null,
              ),
              const SizedBox(height: 13),
              GWidgetTextField(
                controller: _notes,
                labelText: 'Notes'.tr,
                maxLines: 2,
                validator: (v) => _method == PaymentMethod.other &&
                        (v?.trim().isEmpty ?? true)
                    ? 'Explain other payment method'.tr
                    : null,
              ),
              const SizedBox(height: 12),
              VisitDetailWidgetFieldProof(
                key: _proofKey,
                visit: state.visit,
                photoKind: PhotoKind.receipt,
                photosRequired: true,
                onChanged: (value) => setState(() => _proof = value),
              ),
              const SizedBox(height: 16),
              GWidgetButton(
                text: 'Send to admin'.tr,
                isEnable: _proofReady,
                fontSize: AppTheme.textSubtitle,
                raduis: 14,
                isLoading: loading,
                loadingSize: 22,
                loadingStrokeWidth: 3,
                onPressed: () => _submit(state),
              ),
            ],
          ),
        );
      },
    );
  }
}
