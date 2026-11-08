import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../domain/rules/visit_rules.dart';
import '../../../domain/usecases/unassign_technician_uc.dart';
import '../../controller/visit_detail_bloc.dart';
import '../visit_detail_helpers.dart';
import '../visit_detail_widget_action_sheet.dart';
import '../visit_detail_widget_parts.dart';

class VisitDetailWidgetUnassignSheet extends StatefulWidget {
  const VisitDetailWidgetUnassignSheet({super.key, required this.visit});
  final VisitDetailModel visit;

  @override
  State<VisitDetailWidgetUnassignSheet> createState() =>
      _VisitDetailWidgetUnassignSheetState();
}

class _VisitDetailWidgetUnassignSheetState
    extends State<VisitDetailWidgetUnassignSheet> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState?.validate() != true) return;
    context.read<VisitDetailBloc>().add(UnassignTechnicianEvent(
        unassignTechnicianParameters: UnassignTechnicianParameters(
            visitID: widget.visit.id!, reason: _reason.text.trim())));
  }

  @override
  Widget build(BuildContext context) {
    return VisitDetailWidgetActionSheet(
      help: 'Takes the technician off this visit so it can be given to someone else.'.tr,
      title: 'Unassign technician'.tr,
      subtitle: widget.visit.technicianModel?.name,
      requestState: (state) => state.unassignTechnicianRequestState,
      builder: (context, state, loading) => Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VisitDetailNotice(
                text: 'The visit goes back to Scheduled until another technician is assigned.'.tr,
                color: AppTheme.pending),
            const SizedBox(height: 14),
            GWidgetTextField(
              controller: _reason,
              labelText: 'Reason (optional)'.tr,
              maxLines: 3,
              maxLength: VisitRules.maxReasonLength,
              validator: (v) =>
                  VisitDetailHelpers.reasonError(v, required: false),
            ),
            const SizedBox(height: 16),
            GWidgetButton(
              text: 'Unassign'.tr,
              fontSize: AppTheme.textSubtitle,
              raduis: 14,
              backgroundColor: AppTheme.statOrange,
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
