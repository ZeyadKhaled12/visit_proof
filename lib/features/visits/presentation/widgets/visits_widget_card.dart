import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visit_proof/features/visit_detail/presentation/screens/visit_detail_scr.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../core/utils/enums/priority_enum.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../visit_detail/domain/rules/visit_rules.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../data/models/visit_detail_models/visit_detail_model.dart';

/// One visit in a list: what it is, for whom, when, and what comes next.
/// Everything else lives on the visit screen.
class VisitsWidgetCard extends StatelessWidget {
  const VisitsWidgetCard(
      {super.key, required this.visit, required this.onReturn});
  final VisitDetailModel visit;

  /// Called after the visit screen closes, since the visit may have changed.
  final VoidCallback onReturn;

  /// What the technician does next on this visit, if anything.
  String? get _nextAction {
    final status = visit.status;
    if (!AppSession.isTechnician || status == null) return null;
    final next = VisitRules.technicianNextStatuses(status);
    if (next.isEmpty) return null;
    switch (next.first) {
      case VisitStatus.onWay:
        return 'Start trip'.tr;
      case VisitStatus.inProgress:
        return 'Start work'.tr;
      case VisitStatus.completed:
        return 'Complete visit'.tr;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusSwitch = VisitStatusSwitch(visitStatusEnum: visit.status);
    final prioritySwitch = PrioritySwitch(priorityEnum: visit.priority);
    final paymentSwitch =
        PaymentStatusSwitch(paymentStatusEnum: visit.paymentStatus);
    final urgent = visit.priority == Priority.emergency ||
        visit.priority == Priority.high;
    final next = _nextAction;
    final radius = BorderRadius.circular(18);

    return Material(
      color: AppTheme.cardColor,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () async {
          if (visit.id == null) return;
          await Navigator.pushNamed(context, VisitDetailScr.route,
              arguments: VisitDetailArgu(visitID: visit.id!).toArgu());
          onReturn();
        },
        highlightColor: AppTheme.primary.withValues(alpha: 0.05),
        splashColor: AppTheme.primary.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppTheme.iconLightGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        VisitDetailPill(
                          text: statusSwitch.getText(),
                          color: statusSwitch.getColor(),
                        ),
                        if (urgent)
                          VisitDetailPill(
                            text: prioritySwitch.getText(),
                            color: prioritySwitch.getColor(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    visit.visitNumber ?? '#VISIT-000',
                    style: AppTheme.font(
                      color: AppTheme.textDarkHint,
                      fontSize: AppTheme.textSmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                visit.client?.name ?? 'no client'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.font(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.textTitle,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                (visit.serviceName ?? '').trim().isNotEmpty
                    ? visit.serviceName!
                    : visit.category?.name?.tr ?? 'no category'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.font(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.textBody,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 18, color: AppTheme.iconGrey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _formatDate(visit.startDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (next != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Next: {0}'.trArgs([next]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.font(
                          color: AppTheme.primary,
                          fontSize: AppTheme.textSmall,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        size: 20, color: AppTheme.primary),
                  ],
                ],
              ),
              if (!AppSession.isTechnician) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.engineering_outlined,
                        size: 18, color: AppTheme.iconGrey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        [
                          visit.technicianModel?.name ??
                              'no technician assigned'.tr,
                          if (visit.site?.city?.name != null)
                            visit.site!.city!.name!.tr,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.font(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.textSmall,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      paymentSwitch.getText(),
                      style: AppTheme.font(
                        color: paymentSwitch.getColor(),
                        fontSize: AppTheme.textSmall,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date'.tr;
    final now = DateTime.now();
    final time = DateFormat('hh:mm a').format(date);
    if (DateUtils.isSameDay(date, now)) return '${'Today'.tr} · $time';
    if (DateUtils.isSameDay(date, now.add(const Duration(days: 1)))) {
      return '${'Tomorrow'.tr} · $time';
    }
    return DateFormat('dd MMM yyyy · hh:mm a').format(date);
  }
}
