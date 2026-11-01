import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/technician_status_enum.dart';
import '../../../../core/utils/general_functions.dart/g_fun_launch.dart';
import '../../../technicians/data/models/technician_model.dart';
import '../../../visit_detail/domain/rules/visit_rules.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/dispatch_rules.dart';
import '../../domain/usecases/set_technician_day_off_uc.dart';
import '../controller/dispatch_bloc.dart';
import 'dispatch_widget_action_sheet.dart';
import 'dispatch_widget_visit_card.dart';
import 'sheets/dispatch_widget_assign_sheet.dart';
import 'sheets/dispatch_widget_redistribute_sheet.dart';

/// One technician's day: drop target, workload, timeline and visits.
class DispatchWidgetTechnicianCard extends StatefulWidget {
  const DispatchWidgetTechnicianCard(
      {super.key, required this.technician, required this.state});
  final TechnicianModel technician;
  final DispatchState state;

  @override
  State<DispatchWidgetTechnicianCard> createState() =>
      _DispatchWidgetTechnicianCardState();
}

class _DispatchWidgetTechnicianCardState
    extends State<DispatchWidgetTechnicianCard> {
  bool _expanded = false;

  TechnicianModel get _technician => widget.technician;
  DispatchState get _state => widget.state;

  /// Preview of dropping [visit] here, used to color the card while dragging.
  TechnicianSuggestion _preview(VisitDetailModel visit) => DispatchRules.rate(
        visit: visit,
        technician: _technician,
        allVisits: _state.visits,
        settings: _state.settings,
        daysOff: _state.daysOff,
        day: _state.day,
        now: DateTime.now(),
      );

  bool _canTake(VisitDetailModel visit) =>
      visit.technicianModel?.id != _technician.id &&
      VisitRules.canAssignTechnician(visit);

  void _onDrop(VisitDetailModel visit) {
    HapticFeedback.selectionClick();
    final preview = _preview(visit);
    DispatchWidgetActionSheet.show(
      context,
      DispatchWidgetAssignSheet(
        visitID: visit.id,
        technician: _technician,
        day: _state.day,
        initialStart: preview.start,
      ),
    );
  }

  void _toggleDayOff(bool isOff, List<VisitDetailModel> movable) {
    context.read<DispatchBloc>().add(SetTechnicianDayOffEvent(
        setTechnicianDayOffParameters: SetTechnicianDayOffParameters(
            technicianID: _technician.id ?? '',
            date: _state.day,
            isOff: isOff)));

    // Visits already planned for that day need a new technician.
    if (isOff && movable.isNotEmpty) {
      DispatchWidgetActionSheet.show(context,
          DispatchWidgetRedistributeSheet(technician: _technician));
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = _state.day;
    final dayVisits =
        DispatchRules.technicianDay(_state.visits, _technician.id, day);
    final movable =
        dayVisits.where(VisitRules.canAssignTechnician).toList();
    final conflictIDs = DispatchRules.conflicts(
            visits: _state.visits, daysOff: _state.daysOff, day: day)
        .map((v) => v.id)
        .toSet();
    final dayOff = DispatchRules.isDayOff(_state.daysOff, _technician.id, day);

    return DragTarget<VisitDetailModel>(
      onWillAcceptWithDetails: (details) => _canTake(details.data),
      onAcceptWithDetails: (details) => _onDrop(details.data),
      builder: (context, candidates, rejected) {
        final dragged = candidates.whereType<VisitDetailModel>().firstOrNull;
        final highlight = dragged == null ? null : _highlightColor(dragged);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: highlight?.withValues(alpha: .08) ?? AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: highlight ??
                  (rejected.isNotEmpty
                      ? AppTheme.iconLightGrey
                      : AppTheme.primary.withValues(alpha: .08)),
              width: highlight == null ? 1 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (highlight ?? AppTheme.primary).withValues(alpha: .10),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  technician: _technician,
                  visitCount: dayVisits.length,
                  dayOff: dayOff,
                  expanded: _expanded,
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
                const SizedBox(height: 12),
                _Workload(dayVisits: dayVisits, state: _state, dayOff: dayOff),
                if (dragged != null) ...[
                  const SizedBox(height: 10),
                  _DropHint(suggestion: _preview(dragged)),
                ],
                if (_expanded) ...[
                  const SizedBox(height: 12),
                  if (dayVisits.isEmpty)
                    VisitDetailEmpty(
                        icon: Icons.event_available_rounded,
                        text: 'No visits on this day'.tr)
                  else
                    for (final visit in dayVisits)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: DispatchWidgetVisitCard(
                          visit: visit,
                          day: day,
                          hasConflict: conflictIDs.contains(visit.id),
                          draggable: VisitRules.canAssignTechnician(visit),
                        ),
                      ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if ((_technician.phone ?? '').isNotEmpty)
                        VisitDetailActionChip(
                          label: 'Call'.tr,
                          icon: Icons.phone_rounded,
                          color: AppTheme.primary,
                          onTap: () =>
                              GFunLaunch.makePhoneCall(_technician.phone!),
                        ),
                      VisitDetailActionChip(
                        label: dayOff ? 'Back to work'.tr : 'Mark day off'.tr,
                        icon: dayOff
                            ? Icons.event_available_rounded
                            : Icons.event_busy_rounded,
                        color: dayOff ? AppTheme.statGreen : AppTheme.pending,
                        onTap: () => _toggleDayOff(!dayOff, movable),
                      ),
                      if (movable.isNotEmpty)
                        VisitDetailActionChip(
                          label: 'Redistribute'.tr,
                          icon: Icons.alt_route_rounded,
                          color: AppTheme.secondary,
                          onTap: () => DispatchWidgetActionSheet.show(
                              context,
                              DispatchWidgetRedistributeSheet(
                                  technician: _technician)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _highlightColor(VisitDetailModel visit) {
    final preview = _preview(visit);
    if (!preview.eligible) return AppTheme.statOrange;
    if (preview.violations.isNotEmpty) return AppTheme.pending;
    return AppTheme.statGreen;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.technician,
    required this.visitCount,
    required this.dayOff,
    required this.expanded,
    required this.onTap,
  });

  final TechnicianModel technician;
  final int visitCount;
  final bool dayOff;
  final bool expanded;
  final VoidCallback onTap;

  /// First two specialties and a count, so the pill fits narrow cards.
  String get _skills {
    final names = (technician.categories ?? const [])
        .map((e) => e.name ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
    if (names.length <= 2) return names.join(', ');
    return '${names.take(2).join(', ')} +${names.length - 2}';
  }

  @override
  Widget build(BuildContext context) {
    final status = TechnicianStatusSwitch(technicianStatusEnum: technician.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          VisitDetailAvatar(
            letter: VisitDetailHelpers.initial(technician.name),
            colors: dayOff
                ? [AppTheme.iconGrey, AppTheme.iconLightGrey]
                : [status.getColor(), AppTheme.primary],
            size: 42,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(technician.name ?? 'Technician'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textSubtitle,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (dayOff)
                      VisitDetailPill(
                          text: 'Day off'.tr,
                          color: AppTheme.statOrange,
                          icon: Icons.event_busy_rounded)
                    else
                      VisitDetailPill(
                          text: status.getText(), color: status.getColor()),
                    VisitDetailPill(
                        text: '{0} visit{1}'.trArgs([visitCount, visitCount == 1 ? '' : 's']),
                        color: AppTheme.primary),
                    if (_skills.isNotEmpty)
                      VisitDetailPill(text: _skills, color: AppTheme.secondary),
                  ],
                ),
              ],
            ),
          ),
          Icon(expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: AppTheme.iconGrey),
        ],
      ),
    );
  }
}

/// Booked time against the working day, plus a mini timeline of visits.
class _Workload extends StatelessWidget {
  const _Workload(
      {required this.dayVisits, required this.state, required this.dayOff});
  final List<VisitDetailModel> dayVisits;
  final DispatchState state;
  final bool dayOff;

  @override
  Widget build(BuildContext context) {
    final settings = state.settings;
    final workMinutes = settings.workEnd - settings.workStart;
    final booked = DispatchRules.bookedMinutes(dayVisits);
    final load = workMinutes <= 0 ? 0.0 : booked / workMinutes;
    final loadColor = load >= 1
        ? AppTheme.statOrange
        : load >= .75
            ? AppTheme.pending
            : AppTheme.statGreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                  dayOff
                      ? 'Not available on this day'.tr
                      : '{0} booked of {1}'.trArgs([VisitDetailHelpers.duration(booked), VisitDetailHelpers.duration(workMinutes)]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.font(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.textCaption,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            if (!dayOff)
              Text('${(load * 100).clamp(0, 999).round()}%',
                  style: AppTheme.font(
                      color: loadColor,
                      fontSize: AppTheme.textSmall,
                      fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          double x(DateTime time) {
            final minutes = time.hour * 60 + time.minute - settings.workStart;
            return (minutes / workMinutes * width).clamp(0, width).toDouble();
          }

          return Container(
            height: 14,
            decoration: BoxDecoration(
              color: dayOff
                  ? AppTheme.statOrange.withValues(alpha: .12)
                  : AppTheme.locationChipBg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Stack(
              children: [
                for (final visit in dayVisits)
                  PositionedDirectional(
                    start: x(visit.startDate!),
                    width: (x(DispatchRules.endOf(visit)) - x(visit.startDate!))
                        .clamp(4, width)
                        .toDouble(),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: VisitDetailHelpers.statusColor(visit.status),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_clock(settings.workStart),
                style: AppTheme.font(color: AppTheme.textLightHint, fontSize: AppTheme.textMicro)),
            Text(_clock(settings.workEnd),
                style: AppTheme.font(color: AppTheme.textLightHint, fontSize: AppTheme.textMicro)),
          ],
        ),
      ],
    );
  }

  String _clock(int minutes) => VisitDetailHelpers.time(
      DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60));
}

/// What happens if the dragged visit is dropped here.
class _DropHint extends StatelessWidget {
  const _DropHint({required this.suggestion});
  final TechnicianSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    if (!suggestion.eligible) {
      return VisitDetailNotice(
          text: suggestion.violations.first.message,
          color: AppTheme.statOrange,
          icon: Icons.block);
    }

    final start = VisitDetailHelpers.time(suggestion.start);
    if (suggestion.violations.isNotEmpty) {
      return VisitDetailNotice(
          text: 'Drop to assign at {0} · {1}'.trArgs([start, suggestion.violations.first.message]),
          color: AppTheme.pending,
          icon: Icons.warning_amber_rounded);
    }

    return VisitDetailNotice(
        text: 'Drop to assign at {0}'.trArgs([start]),
        color: AppTheme.statGreen,
        icon: Icons.check_circle_rounded);
  }
}
