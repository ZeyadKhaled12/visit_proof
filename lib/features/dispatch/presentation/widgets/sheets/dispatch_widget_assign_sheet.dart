import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../../technicians/data/models/technician_model.dart';
import '../../../../visit_detail/domain/rules/visit_rules.dart';
import '../../../../visit_detail/domain/usecases/assign_technician_uc.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../../domain/rules/dispatch_rules.dart';
import '../../controller/dispatch_bloc.dart';
import '../dispatch_widget_action_sheet.dart';
import 'dispatch_widget_time_picker.dart';
import 'dispatch_widget_violations.dart';

/// Confirms an assignment: pick the time, see every rule, then assign.
class DispatchWidgetAssignSheet extends StatefulWidget {
  const DispatchWidgetAssignSheet({
    super.key,
    required this.visitID,
    required this.technician,
    required this.day,
    this.initialStart,
  });

  final String? visitID;
  final TechnicianModel technician;
  final DateTime day;
  final DateTime? initialStart;

  @override
  State<DispatchWidgetAssignSheet> createState() =>
      _DispatchWidgetAssignSheetState();
}

class _DispatchWidgetAssignSheetState extends State<DispatchWidgetAssignSheet> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  late DateTime _start;

  @override
  void initState() {
    super.initState();
    final state = context.read<DispatchBloc>().state;
    final own = state.visitById(widget.visitID)?.startDate;
    _start = widget.initialStart ??
        (own != null && DispatchRules.sameDay(own, widget.day)
            ? own
            : DispatchRules.atMinutes(widget.day, state.settings.workStart));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DispatchWidgetActionSheet(
      title: 'Assign visit',
      subtitle: 'To ${widget.technician.name ?? 'technician'}',
      requestState: (state) => state.assignRequestState,
      builder: (context, state, loading) {
        final visit = state.visitById(widget.visitID);
        if (visit == null) {
          return const VisitDetailEmpty(
              icon: Icons.search_off_rounded,
              text: 'This visit is no longer available');
        }

        final violations = DispatchRules.evaluate(
          visit: visit,
          technician: widget.technician,
          start: _start,
          allVisits: state.visits,
          settings: state.settings,
          daysOff: state.daysOff,
          now: DateTime.now(),
        );
        final blocked = violations.any((e) => e.blocks);
        final warned = violations.isNotEmpty && !blocked;

        return Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Route(
                  visitNumber: visit.visitNumber,
                  service: visit.serviceName,
                  technician: widget.technician.name),
              const SizedBox(height: 14),
              DispatchWidgetTimePicker(
                value: _start,
                durationInMin: visit.durationInMin ?? 0,
                onChanged: (value) => setState(() => _start = value),
              ),
              const SizedBox(height: 14),
              DispatchWidgetViolations(violations: violations),
              if (warned) ...[
                const SizedBox(height: 12),
                GWidgetTextField(
                  controller: _reason,
                  labelText: 'Reason to continue anyway',
                  maxLines: 2,
                  maxLength: VisitRules.maxReasonLength,
                  validator: (v) =>
                      VisitDetailHelpers.reasonError(v, required: true),
                ),
              ],
              const SizedBox(height: 14),
              GWidgetButton(
                text: warned ? 'Assign anyway' : 'Assign',
                fontSize: AppTheme.textSubtitle,
                raduis: 14,
                isEnable: !blocked,
                isLoading: loading,
                loadingSize: 22,
                loadingStrokeWidth: 3,
                backgroundColor: warned ? AppTheme.pending : null,
                gradient: blocked || warned
                    ? null
                    : LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary]),
                onPressed: () {
                  if (_form.currentState?.validate() != true) return;
                  context.read<DispatchBloc>().add(DispatchAssignEvent(
                      assignTechnicianParameters: AssignTechnicianParameters(
                          visitID: visit.id!,
                          technician: widget.technician,
                          startDate: _start == visit.startDate ? null : _start,
                          reason: warned ? _reason.text.trim() : null)));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Route extends StatelessWidget {
  const _Route({this.visitNumber, this.service, this.technician});
  final String? visitNumber;
  final String? service;
  final String? technician;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.primary.withValues(alpha: .10),
          AppTheme.secondary.withValues(alpha: .08),
        ]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(visitNumber ?? 'Visit',
                    style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textBody,
                        fontWeight: FontWeight.w800)),
                Text(service ?? 'No service',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        color: AppTheme.textSecondary, fontSize: AppTheme.textSmall)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward_rounded, color: AppTheme.primary),
          ),
          VisitDetailAvatar(
            letter: VisitDetailHelpers.initial(technician),
            colors: [AppTheme.primary, AppTheme.secondary],
            size: 34,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(technician ?? 'Technician',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.font(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.textBody,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
