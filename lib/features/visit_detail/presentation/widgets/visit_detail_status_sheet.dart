import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/configs/app_fonts.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_bottom_sheet.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_drop_down.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_text_field.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/usecases/visit_detail_actions_uc.dart';

class VisitDetailStatusSheet extends StatefulWidget {
  final VisitDetailModel visit;
  const VisitDetailStatusSheet({super.key, required this.visit});
  @override
  State<VisitDetailStatusSheet> createState() => _VisitDetailStatusSheetState();
}

class _VisitDetailStatusSheetState extends State<VisitDetailStatusSheet> {
  VisitStatus? selected;
  bool exceptionalApproval = false;
  String? _reasonErrorMsg;
  final reason = TextEditingController();
  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  List<VisitStatus> get options {
    switch (widget.visit.status) {
      case VisitStatus.draft:
        return [
          VisitStatus.scheduled,
          VisitStatus.cancel
        ]; // Assign via technician sheet.
      case VisitStatus.scheduled:
        return [VisitStatus.draft, VisitStatus.cancel];
      case VisitStatus.assigned:
        return [VisitStatus.onWay, VisitStatus.inProgress, VisitStatus.cancel];
      case VisitStatus.onWay:
        return [
          VisitStatus.assigned,
          VisitStatus.inProgress,
          VisitStatus.cancel
        ];
      case VisitStatus.inProgress:
        return [
          VisitStatus.assigned,
          VisitStatus.onWay,
          VisitStatus.completed,
          VisitStatus.cancel
        ];
      case VisitStatus.completed:
        return [VisitStatus.inProgress]; // Reopen
      case VisitStatus.cancel:
        return [VisitStatus.draft, VisitStatus.scheduled]; // Reactivate
      case null:
        return [];
    }
  }

  bool get needsReason =>
      selected == VisitStatus.cancel ||
      widget.visit.status == VisitStatus.completed ||
      widget.visit.status == VisitStatus.cancel ||
      (widget.visit.status == VisitStatus.inProgress &&
          selected != VisitStatus.completed) ||
      (widget.visit.status == VisitStatus.onWay &&
          selected == VisitStatus.assigned);

  bool get needsApproval =>
      widget.visit.status == VisitStatus.inProgress &&
      (selected == VisitStatus.cancel ||
          selected == VisitStatus.assigned ||
          selected == VisitStatus.onWay);

  @override
  Widget build(BuildContext context) => GWidgetBottomSheet(
        title: widget.visit.status == VisitStatus.completed
            ? 'Reopen visit'
            : widget.visit.status == VisitStatus.cancel
                ? 'Reactivate visit'
                : 'Change visit status',
        subtitle:
            'Only allowed transitions are shown. Financial history is preserved.',
        body: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              GWidgetDropDown<VisitStatus>(
                  labelText: 'Move to',
                  value: selected,
                  items: options
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                              VisitStatusSwitch(visitStatusEnum: s).getText(),
                              style: AppFonts(color: AppColors.textPrimary))))
                      .toList(),
                  onChanged: (s) => setState(() {
                        selected = s;
                        exceptionalApproval = false;
                      })),
              if (needsReason) ...[
                const SizedBox(height: 14),
                GWidgetTextField(
                    controller: reason,
                    errorMsg: _reasonErrorMsg,
                    labelText: 'Why is this necessary?',
                    maxLines: 3),
              ],
              if (needsApproval)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  value: exceptionalApproval,
                  onChanged: (v) =>
                      setState(() => exceptionalApproval = v ?? false),
                  title: Text('I approve this exceptional correction',
                      style:
                          AppFonts(fontSize: 12, color: AppColors.textPrimary)),
                ),
              // if (selected == VisitStatus.completed &&
              //     (widget.visit.requireBeforeWorkPhotos == true ||
              //         widget.visit.requireAfterWorkPhotos == true ||
              //         (widget.visit.checkList ?? []).isNotEmpty))
              //   Padding(
              //       padding: const EdgeInsets.symmetric(vertical: 8),
              //       child: Text(
              //           'Completion is blocked until checklist and photo proof can be verified in a dedicated proof model.',
              //           style: AppFonts(
              //               color: AppColors.statOrange, fontSize: 12))),
              const SizedBox(height: 22),
              GWidgetButton(
                  text: 'Confirm status change',
                  fontSize: 14,
                  isEnable: selected != null,
                  onPressed: () {
                    if (selected == null) return;
                    if (needsReason && reason.text.trim().length < 8) {
                      setState(() {
                        _reasonErrorMsg =
                            'This field must be more than 8 characters';
                      });
                      return;
                    }
                    if (needsApproval && !exceptionalApproval) return;
                    Navigator.pop(
                        context,
                        ChangeVisitStatusParameters(
                            visitID: widget.visit.id!,
                            status: selected!,
                            reason: reason.text.trim(),
                            exceptionalApproval: exceptionalApproval));
                  }),
            ])),
      );
}
