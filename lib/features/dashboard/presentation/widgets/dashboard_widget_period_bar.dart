import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/general_widgets/g_widget_choice_chip.dart';
import '../../domain/rules/dashboard_period.dart';
import '../controller/dashboard_bloc.dart';

/// Global date range: presets plus a custom range. Every screen of the
/// dashboard reads the same period, so drill-downs stay in context.
class DashboardWidgetPeriodBar extends StatelessWidget {
  const DashboardWidgetPeriodBar({super.key, required this.period});
  final DashboardPeriod period;

  static List<(DashboardRange, String)> get _presets => [
    (DashboardRange.today, 'Today'.tr),
    (DashboardRange.last7Days, '7 days'.tr),
    (DashboardRange.last30Days, '30 days'.tr),
    (DashboardRange.thisMonth, 'This month'.tr),
  ];

  void _select(BuildContext context, DashboardPeriod value) =>
      context.read<DashboardBloc>().add(ChangeDashboardPeriodEvent(period: value));

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange:
          DateTimeRange(start: period.from, end: period.lastDay),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: AppTheme.onPrimary,
            surface: AppTheme.surface,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !context.mounted) return;
    _select(
        context,
        DashboardPeriod.of(DashboardRange.custom,
            now: now, customStart: picked.start, customEnd: picked.end));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final (range, label) in _presets) ...[
            GWidgetChoiceChip(
              label: label,
              color: AppTheme.primary,
              selected: period.range == range,
              onTap: () => _select(
                  context, DashboardPeriod.of(range, now: DateTime.now())),
            ),
            const SizedBox(width: 8),
          ],
          GWidgetChoiceChip(
            label: period.range == DashboardRange.custom
                ? period.dateLabel
                : 'Custom…'.tr,
            color: AppTheme.primary,
            selected: period.range == DashboardRange.custom,
            onTap: () => _pickRange(context),
          ),
        ],
      ),
    );
  }
}
