import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../configs/app_theme.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/dispatch_rules.dart';
import 'dispatch_widget_action_sheet.dart';
import 'sheets/dispatch_widget_visit_sheet.dart';

/// Compact visit card. With [draggable], a long press picks it up so it can
/// be dropped on a technician.
class DispatchWidgetVisitCard extends StatelessWidget {
  const DispatchWidgetVisitCard({
    super.key,
    required this.visit,
    required this.day,
    this.draggable = false,
    this.hasConflict = false,
    this.width,
  });

  final VisitDetailModel visit;
  final DateTime day;
  final bool draggable;
  final bool hasConflict;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final card = _Card(
        visit: visit,
        day: day,
        hasConflict: hasConflict,
        width: width,
        onTap: () => DispatchWidgetActionSheet.show(
            context, DispatchWidgetVisitSheet(visitID: visit.id)));

    if (!draggable) return card;

    return LongPressDraggable<VisitDetailModel>(
      data: visit,
      onDragStarted: HapticFeedback.mediumImpact,
      feedback: Material(
        color: AppTheme.onPrimary.withValues(alpha: 0),
        child: Transform.rotate(
          angle: -0.03,
          child: SizedBox(
            width: 250,
            child: _Card(visit: visit, day: day, lifted: true, onTap: () {}),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: .35, child: card),
      child: card,
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.visit,
    required this.day,
    required this.onTap,
    this.hasConflict = false,
    this.lifted = false,
    this.width,
  });

  final VisitDetailModel visit;
  final DateTime day;
  final VoidCallback onTap;
  final bool hasConflict;
  final bool lifted;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final statusColor = VisitDetailHelpers.statusColor(visit.status);
    final priorityColor = VisitDetailHelpers.priorityColor(visit.priority);
    final start = visit.startDate;
    final otherDay = start != null && !DispatchRules.sameDay(start, day);

    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: BorderDirectional(start: BorderSide(color: priorityColor, width: 5)),
            ),
            padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(visit.visitNumber ?? 'Visit'.tr,
                          style: AppTheme.font(
                              color: AppTheme.textPrimary,
                              fontSize: AppTheme.textSmall,
                              fontWeight: FontWeight.w800)),
                    ),
                    if (hasConflict) ...[
                      Icon(Icons.warning_amber_rounded,
                          size: 16, color: AppTheme.statOrange),
                      const SizedBox(width: 4),
                    ],
                    _Dot(color: statusColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(VisitDetailHelpers.statusText(visit.status),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.font(
                              color: statusColor,
                              fontSize: AppTheme.textMicro,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(visit.serviceName ?? 'No service'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textBody,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(visit.client?.name ?? 'No client'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        color: AppTheme.textSecondary, fontSize: AppTheme.textSmall)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 13,
                        color: otherDay ? AppTheme.pending : AppTheme.iconGrey),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                          start == null
                              ? 'No time'.tr
                              : otherDay
                                  ? VisitDetailHelpers.dateTime(start)
                                  : '${VisitDetailHelpers.time(start)} · '
                                      '${VisitDetailHelpers.duration(visit.durationInMin)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.font(
                              color: otherDay
                                  ? AppTheme.pending
                                  : AppTheme.textDarkHint,
                              fontSize: AppTheme.textCaption,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
