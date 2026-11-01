import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/usecase/base_use_case.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../core/utils/enums/technician_status_enum.dart';
import '../../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../../core/utils/general_widgets/g_widget_add_btn.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../../technicians/data/models/technician_detail_model.dart';
import '../../../../technicians/data/models/technician_model.dart';
import '../../../../technicians/presentation/screens/add_tech_scr.dart';
import '../../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../domain/rules/visit_rules.dart';
import '../../../domain/usecases/assign_technician_uc.dart';
import '../../controller/visit_detail_bloc.dart';
import '../visit_detail_helpers.dart';
import '../visit_detail_widget_action_sheet.dart';
import '../visit_detail_widget_parts.dart';

/// Picks a technician the same way add_visit does: a searchable dropdown
/// fed by GetTechniciansUc, plus "Add New Technician".
class VisitDetailWidgetAssignSheet extends StatefulWidget {
  const VisitDetailWidgetAssignSheet({super.key, required this.visit});
  final VisitDetailModel visit;

  @override
  State<VisitDetailWidgetAssignSheet> createState() =>
      _VisitDetailWidgetAssignSheetState();
}

class _VisitDetailWidgetAssignSheetState
    extends State<VisitDetailWidgetAssignSheet> {
  /// Technicians created from this sheet, until the list is reloaded.
  final List<TechnicianModel> _added = [];
  TechnicianModel? _selected;

  @override
  void initState() {
    super.initState();
    context
        .read<VisitDetailBloc>()
        .add(const GetVisitTechniciansEvent(noParameters: NoParameters()));
  }

  List<TechnicianModel> _choices(List<TechnicianModel> loaded) {
    final currentID = widget.visit.technicianModel?.id;
    final loadedIDs = loaded.map((e) => e.id).toSet();
    return [
      ...loaded,
      ..._added.where((e) => !loadedIDs.contains(e.id)),
    ].where((e) => e.id != currentID).toList();
  }

  bool _matchesCategory(TechnicianModel technician) =>
      widget.visit.category != null &&
      (technician.categories ?? const []).contains(widget.visit.category);

  Future<void> _addTechnician() async {
    final data = await Navigator.pushNamed(context, AddTechScr.route);
    if (data is TechnicianDetailModel) {
      final technician = data.convertToTechnicianModel();
      setState(() {
        _added.add(technician);
        _selected = technician;
      });
    }
  }

  void _submit() {
    context.read<VisitDetailBloc>().add(AssignTechnicianEvent(
        assignTechnicianParameters: AssignTechnicianParameters(
            visitID: widget.visit.id!, technician: _selected!)));
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.visit.technicianModel;
    final error = VisitRules.assignError(widget.visit);
    final draft = VisitRules.statusOf(widget.visit) == VisitStatus.draft;

    return VisitDetailWidgetActionSheet(
      title: current == null ? 'Assign technician'.tr : 'Reassign technician'.tr,
      subtitle: current == null
          ? 'Technicians busy at this time are rejected automatically.'.tr
          : 'Currently {0}'.trArgs([current.name ?? 'assigned'.tr]),
      requestState: (state) => state.assignTechnicianRequestState,
      builder: (context, state, loading) {
        final choices = _choices(state.technicians);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null) ...[
              VisitDetailNotice(
                  text: error, color: AppTheme.statOrange, icon: Icons.block),
              const SizedBox(height: 14),
            ] else if (draft) ...[
              VisitDetailNotice(
                  text: 'This draft is complete, so assigning a technician moves it straight to Assigned.'.tr,
                  color: AppTheme.primary),
              const SizedBox(height: 14),
            ],
            GWidgetDropDown<TechnicianModel>(
              labelText: 'Technician'.tr,
              searchHintText: 'Search for a technician'.tr,
              enableSearch: true,
              loading: state.getTechniciansRequestState == RequestState.loading,
              value: _selected,
              onChanged: (technician) =>
                  setState(() => _selected = technician),
              items: choices
                  .map((technician) => DropdownMenuItem(
                        value: technician,
                        child: Text(technician.name ?? '',
                            style: AppTheme.font(fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: GWidgetAddBtn(
                  text: 'Add New Technician'.tr, onTap: _addTechnician),
            ),
            if (_selected != null) ...[
              const SizedBox(height: 12),
              _SelectedTechnician(
                technician: _selected!,
                matchesCategory: _matchesCategory(_selected!),
              ),
            ],
            const SizedBox(height: 16),
            GWidgetButton(
              text: 'Assign'.tr,
              fontSize: AppTheme.textSubtitle,
              raduis: 14,
              isEnable: _selected != null && error == null,
              isLoading: loading,
              loadingSize: 22,
              loadingStrokeWidth: 3,
              gradient: _selected == null || error != null
                  ? null
                  : LinearGradient(
                      colors: [AppTheme.primary, AppTheme.secondary]),
              onPressed: _submit,
            ),
          ],
        );
      },
    );
  }
}

class _SelectedTechnician extends StatelessWidget {
  const _SelectedTechnician(
      {required this.technician, required this.matchesCategory});
  final TechnicianModel technician;
  final bool matchesCategory;

  @override
  Widget build(BuildContext context) {
    final status =
        TechnicianStatusSwitch(technicianStatusEnum: technician.status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.primary.withValues(alpha: .10),
          AppTheme.secondary.withValues(alpha: .06),
        ]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          VisitDetailAvatar(
            letter: VisitDetailHelpers.initial(technician.name),
            colors: [status.getColor(), AppTheme.primary],
            size: 42,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(technician.name ?? 'Technician'.tr,
                    style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textBodyLarge,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    VisitDetailPill(
                        text: status.getText(), color: status.getColor()),
                    VisitDetailPill(
                        text: '{0} open jobs'.trArgs([technician.openJobs ?? 0]),
                        color: AppTheme.iconGrey),
                    if (matchesCategory)
                      VisitDetailPill(
                          text: 'Category match'.tr,
                          color: AppTheme.secondary,
                          icon: Icons.star_rounded),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
