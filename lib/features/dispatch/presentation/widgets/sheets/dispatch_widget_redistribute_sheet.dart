import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../technicians/data/models/technician_model.dart';
import '../../../../visit_detail/domain/rules/visit_rules.dart';
import '../../../../visit_detail/domain/usecases/assign_technician_uc.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../../domain/rules/dispatch_rules.dart';
import '../../controller/dispatch_bloc.dart';
import '../dispatch_widget_action_sheet.dart';
import 'dispatch_widget_plan_preview.dart';

/// Moves a technician's planned visits of the day to the best colleagues,
/// e.g. when the technician calls in sick.
class DispatchWidgetRedistributeSheet extends StatelessWidget {
  const DispatchWidgetRedistributeSheet({super.key, required this.technician});
  final TechnicianModel technician;

  @override
  Widget build(BuildContext context) {
    return DispatchWidgetActionSheet(
      help: 'Moves the visits of this technician to other technicians.'.tr,
      title: 'Redistribute visits'.tr,
      subtitle: 'From {0}'.trArgs([technician.name ?? 'technician'.tr]),
      requestState: (state) => state.bulkAssignRequestState,
      builder: (context, state, loading) {
        final day = state.day;
        final dayVisits =
            DispatchRules.technicianDay(state.visits, technician.id, day);
        final movable = dayVisits.where(VisitRules.canAssignTechnician).toList();
        final started = dayVisits.length -
            movable.length -
            dayVisits.where(VisitRules.isClosed).length;

        if (movable.isEmpty) {
          return VisitDetailEmpty(
              icon: Icons.task_alt_rounded,
              text: 'No visits on this day can be moved'.tr);
        }

        final plans = DispatchRules.planAssignments(
          visits: movable,
          technicians: state.technicians,
          allVisits: state.visits,
          settings: state.settings,
          daysOff: state.daysOff,
          day: day,
          now: DateTime.now(),
        );
        final ready = plans.where((p) => p.ok).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VisitDetailNotice(
              text: 'Plan for {0}. Each visit goes to the best available colleague at the closest time.'.trArgs([VisitDetailHelpers.date(day)]),
              color: AppTheme.primary,
              icon: Icons.alt_route_rounded,
            ),
            if (started > 0) ...[
              const SizedBox(height: 8),
              VisitDetailNotice(
                text: '{0} visit{1} already under way and stay{2} with {3}.'.trArgs([started, started == 1 ? ' is' : 's are', started == 1 ? 's' : '', technician.name ?? 'the technician'.tr]),
                color: AppTheme.pending,
                icon: Icons.warning_amber_rounded,
              ),
            ],
            const SizedBox(height: 12),
            DispatchWidgetPlanPreview(plans: plans),
            const SizedBox(height: 8),
            GWidgetButton(
              text: ready.isEmpty
                  ? 'Nobody is available'.tr
                  : 'Move {0} of {1}'.trArgs([ready.length, plans.length]),
              fontSize: AppTheme.textSubtitle,
              raduis: 14,
              isEnable: ready.isNotEmpty,
              isLoading: loading,
              loadingSize: 22,
              loadingStrokeWidth: 3,
              backgroundColor: AppTheme.primary,
              onPressed: () => context.read<DispatchBloc>().add(
                  DispatchBulkAssignEvent(assignments: [
                for (final plan in ready)
                  AssignTechnicianParameters(
                    visitID: plan.visit.id!,
                    technician: plan.technician!,
                    startDate: plan.start,
                    reason: 'Redistributed from {0}{1}'.trArgs([technician.name ?? 'technician'.tr, plan.warnings.isEmpty ? '' : ' · ${plan.warnings.first.message}']),
                  ),
              ])),
            ),
          ],
        );
      },
    );
  }
}
