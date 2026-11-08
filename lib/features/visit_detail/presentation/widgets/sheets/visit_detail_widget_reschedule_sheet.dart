import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_functions.dart/g_fun_date_pick.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../domain/rules/visit_rules.dart';
import '../../../domain/usecases/reschedule_visit_uc.dart';
import '../../controller/visit_detail_bloc.dart';
import '../visit_detail_helpers.dart';
import '../visit_detail_widget_action_sheet.dart';
import '../visit_detail_widget_parts.dart';

class VisitDetailWidgetRescheduleSheet extends StatefulWidget {
  const VisitDetailWidgetRescheduleSheet({super.key, required this.visit});
  final VisitDetailModel visit;

  @override
  State<VisitDetailWidgetRescheduleSheet> createState() =>
      _VisitDetailWidgetRescheduleSheetState();
}

class _VisitDetailWidgetRescheduleSheetState
    extends State<VisitDetailWidgetRescheduleSheet> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final start = widget.visit.startDate;
    if (start != null) {
      _setDate(start);
      _setTime(TimeOfDay.fromDateTime(start));
    }
  }

  @override
  void dispose() {
    _reason.dispose();
    _dateText.dispose();
    _timeText.dispose();
    super.dispose();
  }

  void _setDate(DateTime date) {
    _date = date;
    _dateText.text = VisitDetailHelpers.date(date);
  }

  void _setTime(TimeOfDay time) {
    _time = time;
    _timeText.text =
        VisitDetailHelpers.time(DateTime(2000, 1, 1, time.hour, time.minute));
  }

  DateTime? get _start {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await GFunDatePick.showCustomDatePicker(context,
        firstDate: DateTime(now.year, now.month, now.day),
        initialDate: _date != null && !_date!.isBefore(now) ? _date : now,
        lastDate: now.add(const Duration(days: 365)));
    if (picked != null) setState(() => _setDate(picked));
  }

  Future<void> _pickTime() async {
    final picked =
        await GFunDatePick.showCustomTimePicker(context, initialTime: _time);
    if (picked != null) setState(() => _setTime(picked));
  }

  void _submit() {
    final start = _start;
    setState(() {
      _dateError = start == null
          ? 'Pick a date and a time'.tr
          : start.isBefore(DateTime.now())
              ? 'The new time must be in the future'.tr
              : null;
    });
    if (_form.currentState?.validate() != true || _dateError != null) return;

    context.read<VisitDetailBloc>().add(RescheduleVisitEvent(
        rescheduleVisitParameters: RescheduleVisitParameters(
            visitID: widget.visit.id!,
            startDate: start!,
            reason: _reason.text.trim())));
  }

  @override
  Widget build(BuildContext context) {
    final technician = widget.visit.technicianModel;

    return VisitDetailWidgetActionSheet(
      help: 'Pick a new date and time for this visit.'.tr,
      title: 'Reschedule visit'.tr,
      subtitle:
          'Currently {0}'.trArgs([VisitDetailHelpers.dateTime(widget.visit.startDate)]),
      requestState: (state) => state.rescheduleRequestState,
      builder: (context, state, loading) => Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickDate,
              child: GWidgetTextField(
                enabled: false,
                controller: _dateText,
                labelText: 'Start date'.tr,
                hintText: 'dd MMM yyyy',
                errorMsg: _dateError,
                suffixIcon: Icon(Icons.date_range_rounded,
                    color: _date == null ? AppTheme.iconGrey : AppTheme.primary),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _pickTime,
              child: GWidgetTextField(
                enabled: false,
                controller: _timeText,
                labelText: 'Start time'.tr,
                hintText: '00:00 AM/PM'.tr,
                suffixIcon: Icon(Icons.watch_later_outlined,
                    color: _time == null ? AppTheme.iconGrey : AppTheme.primary),
              ),
            ),
            if (technician != null) ...[
              const SizedBox(height: 14),
              VisitDetailNotice(
                  text: 'We will check that {0} is free at the new time.'.trArgs([technician.name ?? 'the technician'.tr]),
                  color: AppTheme.primary,
                  icon: Icons.event_busy_rounded),
            ],
            const SizedBox(height: 14),
            GWidgetTextField(
              controller: _reason,
              labelText: 'Reason (optional)'.tr,
              maxLines: 2,
              maxLength: VisitRules.maxReasonLength,
              validator: (v) =>
                  VisitDetailHelpers.reasonError(v, required: false),
            ),
            const SizedBox(height: 16),
            GWidgetButton(
              text: 'Save new time'.tr,
              fontSize: AppTheme.textSubtitle,
              raduis: 14,
              backgroundColor: AppTheme.pending,
              isLoading: loading,
              loadingSize: 22,
              loadingStrokeWidth: 3,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
