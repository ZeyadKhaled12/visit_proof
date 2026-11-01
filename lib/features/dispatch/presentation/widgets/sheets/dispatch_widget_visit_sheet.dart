import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/usecase/base_use_case.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../core/utils/enums/priority_enum.dart';
import '../../../../../core/utils/general_widgets/g_widget_choice_chip.dart';
import '../../../../visit_detail/domain/rules/visit_rules.dart';
import '../../../../visit_detail/domain/usecases/update_visit_info_uc.dart';
import '../../../../visit_detail/presentation/screens/visit_detail_scr.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../controller/dispatch_bloc.dart';
import '../dispatch_widget_action_sheet.dart';
import 'dispatch_widget_reschedule_sheet.dart';
import 'dispatch_widget_status_sheet.dart';
import 'dispatch_widget_suggest_sheet.dart';
import 'dispatch_widget_unassign_sheet.dart';

/// Quick view of a visit with every dispatch action in one place.
class DispatchWidgetVisitSheet extends StatelessWidget {
  const DispatchWidgetVisitSheet({super.key, required this.visitID});
  final String? visitID;

  void _changePriority(
      BuildContext context, VisitDetailModel visit, Priority priority) {
    context.read<DispatchBloc>().add(DispatchChangePriorityEvent(
        updateVisitInfoParameters: UpdateVisitInfoParameters(
            visitID: visit.id!,
            priority: priority,
            problemDescription: visit.problemDescription ?? '',
            notes: visit.notes ?? '',
            requireBeforeWorkPhotos: visit.requireBeforeWorkPhotos ?? false,
            requireAfterWorkPhotos: visit.requireAfterWorkPhotos ?? false)));
  }

  Future<void> _openDetails(BuildContext context, String visitID) async {
    final bloc = context.read<DispatchBloc>();
    await Navigator.pushNamed(context, VisitDetailScr.route,
        arguments: VisitDetailArgu(visitID: visitID).toArgu());
    bloc.add(const GetDispatchBoardEvent(noParameters: NoParameters()));
  }

  @override
  Widget build(BuildContext context) {
    return DispatchWidgetActionSheet(
      title: 'Visit'.tr,
      builder: (context, state, loading) {
        final visit = state.visitById(visitID);
        if (visit == null) {
          return VisitDetailEmpty(
              icon: Icons.search_off_rounded,
              text: 'This visit is no longer available'.tr);
        }

        final technician = visit.technicianModel;
        final status = VisitRules.statusOf(visit);
        final changingPriority =
            state.changePriorityRequestState == RequestState.loading;
        void open(Widget sheet) =>
            DispatchWidgetActionSheet.show(context, sheet);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(visit.visitNumber ?? 'Visit'.tr,
                      style: AppTheme.font(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.textTitle,
                          fontWeight: FontWeight.w800)),
                ),
                VisitDetailPill(
                  text: VisitDetailHelpers.statusText(status),
                  color: VisitDetailHelpers.statusColor(status),
                  icon: VisitDetailHelpers.statusIcon(status),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _Line(
                icon: Icons.build_circle_rounded,
                text: visit.serviceName ?? 'No service'.tr),
            _Line(
                icon: Icons.person_rounded,
                text: visit.client?.name ?? 'No client'.tr),
            _Line(
                icon: Icons.location_on_rounded,
                text: VisitDetailHelpers.site(visit.site)),
            _Line(
                icon: Icons.schedule_rounded,
                text: '${VisitDetailHelpers.dateTime(visit.startDate)} · '
                    '${VisitDetailHelpers.duration(visit.durationInMin)}'),
            _Line(
                icon: Icons.engineering_rounded,
                text: technician?.name ?? 'Waiting for a technician'.tr,
                color: technician == null ? AppTheme.pending : null),
            if (VisitRules.canEditInfo(visit)) ...[
              const SizedBox(height: 12),
              Text('Priority'.tr,
                  style: AppTheme.font(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.textBody,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              IgnorePointer(
                ignoring: changingPriority,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final priority in Priority.values)
                      GWidgetChoiceChip(
                        label: VisitDetailHelpers.priorityText(priority),
                        color: VisitDetailHelpers.priorityColor(priority),
                        selected: (visit.priority ?? Priority.normal) == priority,
                        onTap: () {
                          if ((visit.priority ?? Priority.normal) != priority) {
                            _changePriority(context, visit, priority);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (VisitRules.canAssignTechnician(visit))
                  VisitDetailActionChip(
                    label: technician == null ? 'Assign'.tr : 'Reassign'.tr,
                    icon: Icons.auto_awesome_rounded,
                    color: AppTheme.primary,
                    onTap: () =>
                        open(DispatchWidgetSuggestSheet(visitID: visit.id)),
                  ),
                if (VisitRules.canUnassignTechnician(visit))
                  VisitDetailActionChip(
                    label: 'Unassign'.tr,
                    icon: Icons.person_remove_rounded,
                    color: AppTheme.statOrange,
                    onTap: () =>
                        open(DispatchWidgetUnassignSheet(visitID: visit.id)),
                  ),
                if (VisitRules.canReschedule(visit))
                  VisitDetailActionChip(
                    label: 'Reschedule'.tr,
                    icon: Icons.edit_calendar_rounded,
                    color: AppTheme.pending,
                    onTap: () =>
                        open(DispatchWidgetRescheduleSheet(visitID: visit.id)),
                  ),
                if (VisitRules.nextStatuses(status).isNotEmpty)
                  VisitDetailActionChip(
                    label: 'Update status'.tr,
                    icon: Icons.route_rounded,
                    color: AppTheme.secondary,
                    onTap: () =>
                        open(DispatchWidgetStatusSheet(visitID: visit.id)),
                  ),
                VisitDetailActionChip(
                  label: 'Full details'.tr,
                  icon: Icons.open_in_new_rounded,
                  color: AppTheme.iconGrey,
                  onTap: () => _openDetails(context, visit.id!),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text, this.color});
  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.font(
                    color: color ?? AppTheme.textDarkHint,
                    fontSize: AppTheme.textBody,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
