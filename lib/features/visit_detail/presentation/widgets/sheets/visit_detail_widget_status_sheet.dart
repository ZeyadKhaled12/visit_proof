import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../configs/app_toasts.dart';
import '../../../../../core/session/app_session.dart';
import '../../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../../invoices/data/models/invoice_detail_model.dart';
import '../../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../domain/rules/visit_rules.dart';
import '../../../domain/usecases/change_visit_status_uc.dart';
import '../../controller/visit_detail_bloc.dart';
import '../visit_detail_helpers.dart';
import '../visit_detail_widget_action_sheet.dart';
import '../visit_detail_widget_field_proof.dart';
import '../visit_detail_widget_parts.dart';

class VisitDetailWidgetStatusSheet extends StatefulWidget {
  const VisitDetailWidgetStatusSheet({
    super.key,
    required this.visit,
    required this.invoice,
    required this.target,
  });

  final VisitDetailModel visit;
  final InvoiceDetailModel? invoice;
  final VisitStatus target;

  @override
  State<VisitDetailWidgetStatusSheet> createState() =>
      _VisitDetailWidgetStatusSheetState();
}

class _VisitDetailWidgetStatusSheetState
    extends State<VisitDetailWidgetStatusSheet> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  final _proofKey = GlobalKey<VisitDetailWidgetFieldProofState>();
  VisitFieldProofValue _proof = const VisitFieldProofValue();

  VisitStatus get _from => VisitRules.statusOf(widget.visit);

  /// Technicians send their live location (and photos) with every move.
  bool get _fieldAction => AppSession.isTechnician;

  bool get _proofReady {
    if (!_fieldAction) return true;
    final target = widget.target;
    return _proof.location != null &&
        _proof.consent &&
        (!VisitRules.needsPresence(target) || _proof.isWithinSite) &&
        (!VisitRules.photosRequired(widget.visit, target) ||
            _proof.photoPaths.isNotEmpty);
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState?.validate() != true) return;
    if (_fieldAction && _proof.isStale) {
      AppToasts.showMessage(
          'Your location was taken a while ago. Updating it, confirm again.'.tr,
          isError: true);
      _proofKey.currentState?.refreshLocation();
      return;
    }
    context.read<VisitDetailBloc>().add(ChangeVisitStatusEvent(
        changeVisitStatusParameters: ChangeVisitStatusParameters(
            visitID: widget.visit.id!,
            status: widget.target,
            reason: _reason.text.trim(),
            location: _fieldAction ? _proof.location : null,
            photoPaths: _fieldAction ? _proof.photoPaths : const [])));
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.target;
    final error =
        VisitRules.statusChangeError(widget.visit, widget.invoice, target);
    final needsReason = VisitRules.needsReason(_from, target);
    final color = target == VisitStatus.cancel
        ? AppTheme.statOrange
        : VisitDetailHelpers.statusColor(target);

    return VisitDetailWidgetActionSheet(
      title: VisitDetailHelpers.statusActionLabel(_from, target),
      subtitle: VisitDetailHelpers.statusHint(target),
      requestState: (state) => state.changeStatusRequestState,
      builder: (context, state, loading) => Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VisitDetailPill(
                    text: VisitDetailHelpers.statusText(_from),
                    color: VisitDetailHelpers.statusColor(_from),
                    icon: VisitDetailHelpers.statusIcon(_from)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: AppTheme.iconGrey),
                ),
                VisitDetailPill(
                    text: VisitDetailHelpers.statusText(target),
                    color: color,
                    icon: VisitDetailHelpers.statusIcon(target)),
              ],
            ),
            const SizedBox(height: 16),
            if (error != null) ...[
              VisitDetailNotice(
                  text: error, color: AppTheme.statOrange, icon: Icons.block),
              const SizedBox(height: 12),
            ],
            if (target == VisitStatus.cancel && widget.invoice != null) ...[
              VisitDetailNotice(
                  text: 'The linked invoice will be marked as cancelled.'.tr,
                  color: AppTheme.pending),
              const SizedBox(height: 12),
            ],
            if (_from == VisitStatus.cancel) ...[
              VisitDetailNotice(
                  text: 'The technician is released and the invoice becomes collectible again.'.tr,
                  color: AppTheme.secondary),
              const SizedBox(height: 12),
            ],
            if (_fieldAction && error == null) ...[
              VisitDetailWidgetFieldProof(
                key: _proofKey,
                visit: widget.visit,
                photoKind: VisitRules.photoKindFor(target),
                photosRequired: VisitRules.photosRequired(widget.visit, target),
                checkPresence: VisitRules.needsPresence(target),
                onChanged: (value) => setState(() => _proof = value),
              ),
              const SizedBox(height: 12),
            ],
            if (needsReason) ...[
              GWidgetTextField(
                controller: _reason,
                labelText: 'Reason'.tr,
                hintText: 'Why is this change needed?'.tr,
                maxLines: 3,
                maxLength: VisitRules.maxReasonLength,
                validator: (v) =>
                    VisitDetailHelpers.reasonError(v, required: true),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            GWidgetButton(
              text: 'Confirm'.tr,
              fontSize: AppTheme.textSubtitle,
              raduis: 14,
              backgroundColor: color,
              isEnable: error == null && _proofReady,
              isLoading: loading,
              loadingSize: 22,
              loadingStrokeWidth: 3,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
