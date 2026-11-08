import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_functions.dart/g_fun_date_pick.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';

/// Date and time tiles for a visit start, with the expected end time.
class DispatchWidgetTimePicker extends StatelessWidget {
  const DispatchWidgetTimePicker({
    super.key,
    required this.value,
    required this.durationInMin,
    required this.onChanged,
  });

  final DateTime value;
  final int durationInMin;
  final ValueChanged<DateTime> onChanged;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await GFunDatePick.showCustomDatePicker(context,
        initialDate: value.isBefore(now) ? now : value,
        firstDate: DateTime(now.year, now.month, now.day),
        lastDate: now.add(const Duration(days: 365)));
    if (picked == null) return;
    onChanged(DateTime(
        picked.year, picked.month, picked.day, value.hour, value.minute));
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await GFunDatePick.showCustomTimePicker(context,
        initialTime: TimeOfDay.fromDateTime(value));
    if (picked == null) return;
    onChanged(DateTime(
        value.year, value.month, value.day, picked.hour, picked.minute));
  }

  @override
  Widget build(BuildContext context) {
    final end = value.add(Duration(minutes: durationInMin));

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _pickDate(context),
            child: VisitDetailStatTile(
                icon: Icons.calendar_month_rounded,
                label: 'Date · tap to change'.tr,
                value: VisitDetailHelpers.date(value),
                color: AppTheme.primary),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => _pickTime(context),
            child: VisitDetailStatTile(
                icon: Icons.schedule_rounded,
                label: 'Until {0}'.trArgs([VisitDetailHelpers.time(end)]),
                value: VisitDetailHelpers.time(value),
                color: AppTheme.primary),
          ),
        ),
      ],
    );
  }
}
