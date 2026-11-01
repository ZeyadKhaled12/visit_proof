import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_functions.dart/g_fun_date_pick.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/dispatch_rules.dart';

/// Week strip to pick the board day, with a dot per day that has visits.
class DispatchWidgetDateStrip extends StatelessWidget {
  const DispatchWidgetDateStrip({
    super.key,
    required this.day,
    required this.visits,
    required this.onChanged,
  });

  final DateTime day;
  final List<VisitDetailModel> visits;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final weekStart = DispatchRules.addDays(day, 1 - day.weekday);
    final today = DispatchRules.dayOf(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppTheme.shadowColor, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.chevron_left_rounded,
                    color: AppTheme.primary),
                onPressed: () => onChanged(DispatchRules.addDays(day, -7)),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await GFunDatePick.showCustomDatePicker(
                        context,
                        initialDate: day,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 730)));
                    if (picked != null) onChanged(picked);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(DateFormat('MMMM yyyy').format(day),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.font(
                                color: AppTheme.textPrimary,
                                fontSize: AppTheme.textSubtitle,
                                fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.expand_more_rounded,
                          size: 18, color: AppTheme.iconGrey),
                    ],
                  ),
                ),
              ),
              if (day != today)
                TextButton(
                  onPressed: () => onChanged(today),
                  child: Text('Today'.tr,
                      style: AppTheme.font(
                          color: AppTheme.primary,
                          fontSize: AppTheme.textBody,
                          fontWeight: FontWeight.w700)),
                ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.chevron_right_rounded,
                    color: AppTheme.primary),
                onPressed: () => onChanged(DispatchRules.addDays(day, 7)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(7, (index) {
              final date = DispatchRules.addDays(weekStart, index);
              final selected = DispatchRules.sameDay(date, day);
              final count = visits
                  .where((v) =>
                      v.status != VisitStatus.cancel &&
                      DispatchRules.sameDay(v.startDate, date))
                  .length;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? LinearGradient(
                              colors: [AppTheme.primary, AppTheme.secondary],
                              begin: AlignmentDirectional.topStart,
                              end: AlignmentDirectional.bottomEnd)
                          : null,
                      color: selected
                          ? null
                          : DispatchRules.sameDay(date, today)
                              ? AppTheme.primary.withValues(alpha: .08)
                              : null,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    // Scales down on narrow phones or large text sizes.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                      children: [
                        Text(DateFormat('EEE').format(date),
                            style: AppTheme.font(
                                color: selected
                                    ? AppTheme.onPrimary
                                    : AppTheme.textSecondary,
                                fontSize: AppTheme.textCaption,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('${date.day}',
                            style: AppTheme.font(
                                color: selected
                                    ? AppTheme.onPrimary
                                    : AppTheme.textPrimary,
                                fontSize: AppTheme.textTitle,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: count == 0
                                ? AppTheme.onPrimary.withValues(alpha: 0)
                                : selected
                                    ? AppTheme.surface
                                    : AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
