import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../../visit_detail/domain/rules/visit_rules.dart';
import '../../../../visit_detail/domain/usecases/reschedule_visit_uc.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../../domain/rules/dispatch_rules.dart';
import '../../controller/dispatch_bloc.dart';
import '../dispatch_widget_action_sheet.dart';
import 'dispatch_widget_time_picker.dart';
import 'dispatch_widget_violations.dart';

/// Moves a visit to another time, keeping its technician if it has one.
class DispatchWidgetRescheduleSheet extends StatefulWidget {
  const DispatchWidgetRescheduleSheet({super.key, required this.visitID});
  final String? visitID;

  @override
  State<DispatchWidgetRescheduleSheet> createState() =>
      _DispatchWidgetRescheduleSheetState();
}

class _DispatchWidgetRescheduleSheetState
    extends State<DispatchWidgetRescheduleSheet> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  late DateTime _start;

  @override
  void initState() {
    super.initState();
    final state = context.read<DispatchBloc>().state;
    final own = state.visitById(widget.visitID)?.startDate;
    final now = DateTime.now();
    _start = own != null && own.isAfter(now)
        ? own
        : DispatchRules.atMinutes(state.day, state.settings.workStart);
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DispatchWidgetActionSheet(
      title: 'Reschedule visit'.tr,
      requestState: (state) => state.rescheduleRequestState,
      builder: (context, state, loading) {
        final visit = state.visitById(widget.visitID);
        if (visit == null) {
          return VisitDetailEmpty(
              icon: Icons.search_off_rounded,
              text: 'This visit is no longer available'.tr);
        }

        final technician = visit.technicianModel;
        final violations = technician == null
            ? [
                if (_start.isBefore(DateTime.now()))
                  DispatchViolation.block(
                      'The start time has already passed.'.tr)
              ]
            : DispatchRules.evaluate(
                visit: visit,
                technician: technician,
                start: _start,
                allVisits: state.visits,
                settings: state.settings,
                daysOff: state.daysOff,
                now: DateTime.now(),
              );
        final unchanged = _start == visit.startDate;
        final blocked = unchanged || violations.any((e) => e.blocks);
        final warned = violations.isNotEmpty && !blocked;

        return Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VisitDetailNotice(
                text: technician == null
                    ? 'Currently {0}'.trArgs([VisitDetailHelpers.dateTime(visit.startDate)])
                    : 'Currently {0} with {1}'.trArgs([VisitDetailHelpers.dateTime(visit.startDate), technician.name ?? 'the technician'.tr]),
                color: AppTheme.primary,
                icon: Icons.event_rounded,
              ),
              const SizedBox(height: 12),
              DispatchWidgetTimePicker(
                value: _start,
                durationInMin: visit.durationInMin ?? 0,
                onChanged: (value) => setState(() => _start = value),
              ),
              const SizedBox(height: 14),
              if (!unchanged) DispatchWidgetViolations(violations: violations),
              const SizedBox(height: 4),
              GWidgetTextField(
                controller: _reason,
                labelText:
                    warned ? 'Reason to continue anyway'.tr : 'Reason (optional)'.tr,
                maxLines: 2,
                maxLength: VisitRules.maxReasonLength,
                validator: (v) =>
                    VisitDetailHelpers.reasonError(v, required: warned),
              ),
              const SizedBox(height: 12),
              GWidgetButton(
                text: warned ? 'Move anyway'.tr : 'Save new time'.tr,
                fontSize: AppTheme.textSubtitle,
                raduis: 14,
                isEnable: !blocked,
                isLoading: loading,
                loadingSize: 22,
                loadingStrokeWidth: 3,
                backgroundColor: AppTheme.pending,
                onPressed: () {
                  if (_form.currentState?.validate() != true) return;
                  context.read<DispatchBloc>().add(DispatchRescheduleEvent(
                      rescheduleVisitParameters: RescheduleVisitParameters(
                          visitID: visit.id!,
                          startDate: _start,
                          reason: _reason.text.trim())));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
