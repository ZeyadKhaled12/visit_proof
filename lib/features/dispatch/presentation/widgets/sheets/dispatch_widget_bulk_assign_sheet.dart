import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_functions.dart/g_fun_date_pick.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_choice_chip.dart';
import '../../../../technicians/data/models/technician_model.dart';
import '../../../../visit_detail/domain/usecases/assign_technician_uc.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../domain/rules/dispatch_rules.dart';
import '../../controller/dispatch_bloc.dart';
import '../dispatch_widget_action_sheet.dart';
import 'dispatch_widget_plan_preview.dart';

/// Assigns several waiting visits at once: to the best technician for each,
/// or all to one technician. Shows the full plan before anything is saved.
class DispatchWidgetBulkAssignSheet extends StatefulWidget {
  const DispatchWidgetBulkAssignSheet({super.key, required this.visitIDs});
  final List<String?> visitIDs;

  @override
  State<DispatchWidgetBulkAssignSheet> createState() =>
      _DispatchWidgetBulkAssignSheetState();
}

class _DispatchWidgetBulkAssignSheetState
    extends State<DispatchWidgetBulkAssignSheet> {
  late DateTime _day = context.read<DispatchBloc>().state.day;

  /// Null means "best technician for each visit".
  TechnicianModel? _technician;

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await GFunDatePick.showCustomDatePicker(context,
        initialDate: _day.isBefore(now) ? now : _day,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: now.add(const Duration(days: 365)));
    if (picked != null) setState(() => _day = DispatchRules.dayOf(picked));
  }

  @override
  Widget build(BuildContext context) {
    return DispatchWidgetActionSheet(
      title: 'Assign {0} visits'.trArgs([widget.visitIDs.length]),
      subtitle: 'Review the plan, then confirm'.tr,
      requestState: (state) => state.bulkAssignRequestState,
      builder: (context, state, loading) {
        final visits = [
          for (final id in widget.visitIDs) state.visitById(id),
        ].whereType<VisitDetailModel>().toList();

        final plans = DispatchRules.planAssignments(
          visits: visits,
          technicians: state.technicians,
          allVisits: state.visits,
          settings: state.settings,
          daysOff: state.daysOff,
          day: _day,
          now: DateTime.now(),
          technician: _technician,
        );
        final ready = plans.where((p) => p.ok).toList();
        final warned = ready.any((p) => p.warnings.isNotEmpty);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Plan for'.tr,
                      style: AppTheme.font(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.textBody,
                          fontWeight: FontWeight.w800)),
                ),
                VisitDetailActionChip(
                  label: VisitDetailHelpers.date(_day),
                  icon: Icons.calendar_month_rounded,
                  color: AppTheme.primary,
                  onTap: _pickDay,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                GWidgetChoiceChip(
                  label: 'Best for each'.tr,
                  color: AppTheme.primary,
                  selected: _technician == null,
                  onTap: () => setState(() => _technician = null),
                ),
                for (final technician in state.technicians)
                  GWidgetChoiceChip(
                    label: technician.name ?? 'Technician'.tr,
                    color: AppTheme.primary,
                    selected: _technician?.id == technician.id,
                    onTap: () => setState(() => _technician = technician),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            DispatchWidgetPlanPreview(plans: plans),
            if (warned) ...[
              const SizedBox(height: 4),
              VisitDetailNotice(
                  text: 'Some assignments break a warning rule. They will be saved with a note in the visit history.'.tr,
                  color: AppTheme.pending,
                  icon: Icons.warning_amber_rounded),
            ],
            const SizedBox(height: 12),
            GWidgetButton(
              text: ready.isEmpty
                  ? 'Nothing can be assigned'.tr
                  : 'Assign {0} of {1}'.trArgs([ready.length, plans.length]),
              fontSize: AppTheme.textSubtitle,
              raduis: 14,
              isEnable: ready.isNotEmpty,
              isLoading: loading,
              loadingSize: 22,
              loadingStrokeWidth: 3,
              onPressed: () => context.read<DispatchBloc>().add(
                  DispatchBulkAssignEvent(assignments: [
                for (final plan in ready)
                  AssignTechnicianParameters(
                    visitID: plan.visit.id!,
                    technician: plan.technician!,
                    startDate: plan.start,
                    reason: plan.warnings.isEmpty
                        ? null
                        : 'Bulk dispatch: {0}'.trArgs([plan.warnings.first.message]),
                  ),
              ])),
            ),
          ],
        );
      },
    );
  }
}
