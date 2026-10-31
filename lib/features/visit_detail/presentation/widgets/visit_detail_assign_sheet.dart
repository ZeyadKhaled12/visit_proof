import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/configs/app_fonts.dart';
import 'package:visit_proof/core/utils/enums/visit_status_enum.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_bottom_sheet.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_drop_down.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_text_field.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/usecases/visit_detail_actions_uc.dart';

class VisitDetailAssignSheet extends StatefulWidget {
  final VisitDetailModel visit;
  final List<TechnicianModel> technicians;
  const VisitDetailAssignSheet(
      {super.key, required this.visit, required this.technicians});
  @override
  State<VisitDetailAssignSheet> createState() => _VisitDetailAssignSheetState();
}

class _VisitDetailAssignSheetState extends State<VisitDetailAssignSheet> {
  TechnicianModel? technician;
  VisitStatus unassignTo = VisitStatus.scheduled;
  final reason = TextEditingController();
  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assigned = widget.visit.technicianModel != null;
    return GWidgetBottomSheet(
      title: assigned ? 'Manage technician' : 'Assign technician',
      subtitle:
          'Current: ${widget.visit.technicianModel?.name ?? 'Unassigned'}',
      body: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            GWidgetDropDown<TechnicianModel>(
                labelText: 'Choose technician',
                value: technician,
                enableSearch: true,
                items: widget.technicians
                    .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name ?? t.id ?? 'Technician',
                            style: AppFonts(color: AppColors.textPrimary))))
                    .toList(),
                onChanged: (v) => setState(() => technician = v)),
            const SizedBox(height: 14),
            GWidgetTextField(
                controller: reason,
                labelText: assigned
                    ? 'Reason for change / removal'
                    : 'Assignment note (optional)',
                maxLines: 2),
            const SizedBox(height: 18),
            GWidgetButton(
                text: assigned ? 'Reassign technician' : 'Assign technician',
                fontSize: 14,
                onPressed: () {
                  if (technician == null) return;
                  if (assigned && reason.text.trim().length < 8) return;
                  Navigator.pop(
                      context,
                      AssignVisitTechnicianParameters(
                          visitID: widget.visit.id!,
                          technician: technician!,
                          reason: reason.text.trim()));
                }),
            if (assigned && widget.visit.status == VisitStatus.assigned) ...[
              const SizedBox(height: 18),
              GWidgetDropDown<VisitStatus>(
                  labelText: 'After removing technician',
                  value: unassignTo,
                  items: [VisitStatus.scheduled, VisitStatus.draft]
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                              VisitStatusSwitch(visitStatusEnum: s).getText(),
                              style: AppFonts())))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => unassignTo = v);
                  }),
              const SizedBox(height: 8),
              TextButton.icon(
                  onPressed: () {
                    if (reason.text.trim().length < 8) return;
                    Navigator.pop(
                        context,
                        UnassignVisitTechnicianParameters(
                            visitID: widget.visit.id!,
                            destination: unassignTo,
                            reason: reason.text.trim()));
                  },
                  icon: const Icon(Icons.person_remove_alt_1_outlined,
                      color: AppColors.statOrange),
                  label: Text('Remove technician',
                      style: AppFonts(color: AppColors.statOrange))),
            ],
          ])),
    );
  }
}
