import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/technician_status_enum.dart';
import '../../../../core/utils/general_functions.dart/g_fun_launch.dart';
import '../../../technicians/data/models/technician_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/visit_rules.dart';
import 'sheets/visit_detail_widget_assign_sheet.dart';
import 'sheets/visit_detail_widget_reschedule_sheet.dart';
import 'sheets/visit_detail_widget_unassign_sheet.dart';
import 'visit_detail_helpers.dart';
import 'visit_detail_widget_action_sheet.dart';
import 'visit_detail_widget_parts.dart';

class VisitDetailWidgetSchedule extends StatelessWidget {
  const VisitDetailWidgetSchedule({super.key, required this.visit});
  final VisitDetailModel visit;

  @override
  Widget build(BuildContext context) {
    final start = visit.startDate;
    final end = start?.add(Duration(minutes: visit.durationInMin ?? 0));

    return VisitDetailSection(
      title: 'Schedule & Technician'.tr,
      icon: Icons.event_available_rounded,
      color: AppTheme.pending,
      actionText: 'Reschedule'.tr,
      actionIcon: Icons.edit_calendar_rounded,
      onAction: VisitRules.canReschedule(visit)
          ? () => VisitDetailWidgetActionSheet.show(
              context, VisitDetailWidgetRescheduleSheet(visit: visit))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: VisitDetailStatTile(
                    icon: Icons.calendar_month_rounded,
                    label: 'Date'.tr,
                    value: VisitDetailHelpers.date(start),
                    color: AppTheme.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: VisitDetailStatTile(
                    icon: Icons.schedule_rounded,
                    label: 'Starts'.tr,
                    value: VisitDetailHelpers.time(start),
                    color: AppTheme.secondary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: VisitDetailStatTile(
                    icon: Icons.timelapse_rounded,
                    label: 'Duration'.tr,
                    value: VisitDetailHelpers.duration(visit.durationInMin),
                    color: AppTheme.statOrange),
              ),
            ],
          ),
          if (end != null && (visit.durationInMin ?? 0) > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.flag_rounded,
                    size: 16, color: AppTheme.statGreen),
                const SizedBox(width: 6),
                Text('Expected to finish around {0}'.trArgs([VisitDetailHelpers.time(end)]),
                    style: AppTheme.font(
                        color: AppTheme.textDarkHint,
                        fontSize: AppTheme.textSmall,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
          const SizedBox(height: 14),
          visit.technicianModel == null
              ? _NoTechnician(visit: visit)
              : _TechnicianCard(
                  visit: visit, technician: visit.technicianModel!),
        ],
      ),
    );
  }
}

class _TechnicianCard extends StatelessWidget {
  const _TechnicianCard({required this.visit, required this.technician});
  final VisitDetailModel visit;
  final TechnicianModel technician;

  @override
  Widget build(BuildContext context) {
    final status = TechnicianStatusSwitch(technicianStatusEnum: technician.status);
    final phone = technician.phone ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.primary.withValues(alpha: .10),
          AppTheme.secondary.withValues(alpha: .06),
        ]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              VisitDetailAvatar(
                letter: VisitDetailHelpers.initial(technician.name),
                colors: [AppTheme.primary, AppTheme.cardAccent],
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
                            fontSize: AppTheme.textSubtitle,
                            fontWeight: FontWeight.w800)),
                    Text('{0} open jobs'.trArgs([technician.openJobs ?? 0]),
                        style: AppTheme.font(
                            color: AppTheme.textSecondary, fontSize: AppTheme.textSmall)),
                  ],
                ),
              ),
              VisitDetailPill(
                  text: status.getText(), color: status.getColor()),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (phone.isNotEmpty)
                VisitDetailActionChip(
                  label: 'Call'.tr,
                  icon: Icons.phone_rounded,
                  color: AppTheme.primary,
                  onTap: () => GFunLaunch.makePhoneCall(phone),
                ),
              if (VisitRules.canAssignTechnician(visit))
                VisitDetailActionChip(
                  label: 'Reassign'.tr,
                  icon: Icons.swap_horiz_rounded,
                  color: AppTheme.secondary,
                  onTap: () => VisitDetailWidgetActionSheet.show(
                      context, VisitDetailWidgetAssignSheet(visit: visit)),
                ),
              if (VisitRules.canUnassignTechnician(visit))
                VisitDetailActionChip(
                  label: 'Unassign'.tr,
                  icon: Icons.person_remove_rounded,
                  color: AppTheme.statOrange,
                  onTap: () => VisitDetailWidgetActionSheet.show(context,
                      VisitDetailWidgetUnassignSheet(visit: visit)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoTechnician extends StatelessWidget {
  const _NoTechnician({required this.visit});
  final VisitDetailModel visit;

  @override
  Widget build(BuildContext context) {
    if (!VisitRules.canAssignTechnician(visit)) {
      return VisitDetailEmpty(
        icon: Icons.engineering_outlined,
        text: 'No technician was assigned to this visit.'.tr,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VisitDetailEmpty(
            icon: Icons.engineering_outlined,
            text: 'No technician assigned yet'.tr),
        const SizedBox(height: 10),
        Center(
          child: VisitDetailActionChip(
            label: 'Assign technician'.tr,
            icon: Icons.person_add_alt_1_rounded,
            color: AppTheme.primary,
            onTap: () => VisitDetailWidgetActionSheet.show(
                context, VisitDetailWidgetAssignSheet(visit: visit)),
          ),
        ),
      ],
    );
  }
}
