import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_functions.dart/g_fun_date_pick.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../../domain/rules/dispatch_rules.dart';
import '../../controller/dispatch_bloc.dart';
import '../dispatch_widget_action_sheet.dart';
import 'dispatch_widget_assign_sheet.dart';

/// Ranks every technician for a visit and explains each ranking.
class DispatchWidgetSuggestSheet extends StatefulWidget {
  const DispatchWidgetSuggestSheet({super.key, required this.visitID});
  final String? visitID;

  @override
  State<DispatchWidgetSuggestSheet> createState() =>
      _DispatchWidgetSuggestSheetState();
}

class _DispatchWidgetSuggestSheetState
    extends State<DispatchWidgetSuggestSheet> {
  late DateTime _day;

  @override
  void initState() {
    super.initState();
    final state = context.read<DispatchBloc>().state;
    final own = state.visitById(widget.visitID)?.startDate;
    final today = DispatchRules.dayOf(DateTime.now());
    // Plan on the visit's own day when it is still ahead, else the board day.
    _day = own != null && !DispatchRules.dayOf(own).isBefore(today)
        ? DispatchRules.dayOf(own)
        : state.day;
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await GFunDatePick.showCustomDatePicker(context,
        initialDate: _day,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: now.add(const Duration(days: 365)));
    if (picked != null) setState(() => _day = DispatchRules.dayOf(picked));
  }

  @override
  Widget build(BuildContext context) {
    return DispatchWidgetActionSheet(
      title: 'Suggested technicians'.tr,
      subtitle: 'Best match first: specialty, free time, distance and status'.tr,
      requestState: (state) => state.assignRequestState,
      builder: (context, state, loading) {
        final visit = state.visitById(widget.visitID);
        if (visit == null) {
          return VisitDetailEmpty(
              icon: Icons.search_off_rounded,
              text: 'This visit is no longer available'.tr);
        }

        final suggestions = DispatchRules.suggest(
          visit: visit,
          technicians: state.technicians,
          allVisits: state.visits,
          settings: state.settings,
          daysOff: state.daysOff,
          day: _day,
          now: DateTime.now(),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('${visit.visitNumber ?? 'Visit'} · '
                      '${visit.serviceName ?? 'No service'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            if (suggestions.isEmpty)
              VisitDetailEmpty(
                  icon: Icons.engineering_outlined,
                  text: 'No other technicians to suggest'.tr)
            else
              for (var i = 0; i < suggestions.length; i++)
                _SuggestionTile(
                  suggestion: suggestions[i],
                  best: i == 0 && suggestions[i].eligible,
                  onTap: suggestions[i].eligible
                      ? () => DispatchWidgetActionSheet.show(
                          context,
                          DispatchWidgetAssignSheet(
                            visitID: visit.id,
                            technician: suggestions[i].technician,
                            day: _day,
                            initialStart: suggestions[i].start,
                          ))
                      : null,
                ),
          ],
        );
      },
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.best,
    required this.onTap,
  });

  final TechnicianSuggestion suggestion;
  final bool best;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final technician = suggestion.technician;
    final eligible = suggestion.eligible;
    final warnings = suggestion.violations.where((e) => !e.blocks).length;

    return Opacity(
      opacity: eligible ? 1 : .55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: best
              ? AppTheme.statGreen.withValues(alpha: .06)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: best
                  ? AppTheme.statGreen
                  : AppTheme.iconLightGrey.withValues(alpha: .5),
              width: best ? 1.5 : 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    VisitDetailAvatar(
                      letter: VisitDetailHelpers.initial(technician.name),
                      size: 38,
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
                          Text(
                              eligible
                                  ? 'Free at {0}'.trArgs([VisitDetailHelpers.time(suggestion.start)])
                                  : suggestion.violations.first.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.font(
                                  color: eligible
                                      ? AppTheme.statGreen
                                      : AppTheme.statOrange,
                                  fontSize: AppTheme.textSmall,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    if (best)
                      VisitDetailPill(
                          text: 'Best match'.tr,
                          color: AppTheme.statGreen,
                          icon: Icons.auto_awesome_rounded)
                    else if (eligible)
                      Icon(Icons.chevron_right_rounded,
                          color: AppTheme.iconGrey),
                  ],
                ),
                if (eligible) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final reason in suggestion.reasons)
                        VisitDetailPill(text: reason, color: AppTheme.primary),
                      if (warnings > 0)
                        VisitDetailPill(
                            text: '{0} warning{1}'.trArgs([warnings, warnings == 1 ? '' : 's']),
                            color: AppTheme.pending,
                            icon: Icons.warning_amber_rounded),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
