import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/enums/priority_enum.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../../../core/utils/general_widgets/g_widget_switcher.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../domain/rules/visit_rules.dart';
import '../../../domain/usecases/update_visit_info_uc.dart';
import '../../controller/visit_detail_bloc.dart';
import '../visit_detail_helpers.dart';
import '../visit_detail_widget_action_sheet.dart';
import '../visit_detail_widget_parts.dart';

class VisitDetailWidgetInfoSheet extends StatefulWidget {
  const VisitDetailWidgetInfoSheet({super.key, required this.visit});
  final VisitDetailModel visit;

  @override
  State<VisitDetailWidgetInfoSheet> createState() =>
      _VisitDetailWidgetInfoSheetState();
}

class _VisitDetailWidgetInfoSheetState
    extends State<VisitDetailWidgetInfoSheet> {
  late final TextEditingController _problem =
      TextEditingController(text: widget.visit.problemDescription ?? '');
  late final TextEditingController _notes =
      TextEditingController(text: widget.visit.notes ?? '');
  late Priority _priority = widget.visit.priority ?? Priority.normal;
  late bool _beforePhotos = widget.visit.requireBeforeWorkPhotos ?? false;
  late bool _afterPhotos = widget.visit.requireAfterWorkPhotos ?? false;

  @override
  void dispose() {
    _problem.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<VisitDetailBloc>().add(UpdateVisitInfoEvent(
        updateVisitInfoParameters: UpdateVisitInfoParameters(
            visitID: widget.visit.id!,
            priority: _priority,
            problemDescription: _problem.text,
            notes: _notes.text,
            requireBeforeWorkPhotos: _beforePhotos,
            requireAfterWorkPhotos: _afterPhotos)));
  }

  @override
  Widget build(BuildContext context) {
    final canChangeProof = VisitRules.canChangeProofRequirements(widget.visit);

    return VisitDetailWidgetActionSheet(
      title: 'Edit job notes'.tr,
      requestState: (state) => state.updateInfoRequestState,
      builder: (context, state, loading) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GWidgetDropDown<Priority>(
            labelText: 'Priority'.tr,
            value: _priority,
            onChanged: (priority) {
              if (priority != null) setState(() => _priority = priority);
            },
            items: Priority.values
                .map((priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(VisitDetailHelpers.priorityText(priority),
                          style: AppTheme.font(
                              color: VisitDetailHelpers.priorityColor(
                                  priority),
                              fontWeight: FontWeight.w700)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          GWidgetTextField(
            controller: _problem,
            labelText: 'Problem'.tr,
            hintText: 'What does the client report?'.tr,
            maxLines: 4,
            maxLength: VisitRules.maxProblemLength,
          ),
          const SizedBox(height: 14),
          GWidgetTextField(
            controller: _notes,
            labelText: 'Notes for the technician'.tr,
            hintText: 'e.g., Gate code, call before arrival...'.tr,
            maxLines: 3,
            maxLength: VisitRules.maxNotesLength,
          ),
          const SizedBox(height: 10),
          if (canChangeProof) ...[
            GWidgetSwitcher(
                title: 'Require before-work photos'.tr,
                subtitle: 'Technician supplies proof during the visit'.tr,
                value: _beforePhotos,
                onChanged: (value) => setState(() => _beforePhotos = value)),
            GWidgetSwitcher(
                title: 'Require after-work photos'.tr,
                subtitle: 'Technician supplies proof during the visit'.tr,
                value: _afterPhotos,
                onChanged: (value) => setState(() => _afterPhotos = value)),
          ] else
            VisitDetailNotice(
                text: 'Photo requirements are locked once the technician is on the way.'.tr,
                color: AppTheme.iconGrey,
                icon: Icons.lock_rounded),
          const SizedBox(height: 16),
          GWidgetButton(
            text: 'Save changes'.tr,
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
    );
  }
}
