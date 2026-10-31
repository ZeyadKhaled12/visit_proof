import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../../visit_detail/domain/rules/visit_rules.dart';
import '../../../../visit_detail/domain/usecases/change_visit_status_uc.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../../domain/rules/dispatch_rules.dart';
import '../../controller/dispatch_bloc.dart';
import '../dispatch_widget_action_sheet.dart';

/// Moves a visit through its workflow. With no technician app yet, the
/// office updates progress (on the way, in progress, completed) from here.
class DispatchWidgetStatusSheet extends StatefulWidget {
  const DispatchWidgetStatusSheet({super.key, required this.visitID});
  final String? visitID;

  @override
  State<DispatchWidgetStatusSheet> createState() =>
      _DispatchWidgetStatusSheetState();
}

class _DispatchWidgetStatusSheetState extends State<DispatchWidgetStatusSheet> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  VisitStatus? _target;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DispatchWidgetActionSheet(
      title: 'Update status',
      requestState: (state) => state.changeStatusRequestState,
      builder: (context, state, loading) {
        final visit = state.visitById(widget.visitID);
        if (visit == null) {
          return const VisitDetailEmpty(
              icon: Icons.search_off_rounded,
              text: 'This visit is no longer available');
        }

        final from = VisitRules.statusOf(visit);
        final options = VisitRules.nextStatuses(from);
        final target = _target;
        final needsReason =
            target != null && VisitRules.needsReason(from, target);

        return Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Currently ${VisitDetailHelpers.statusText(from)}',
                  style: AppTheme.font(
                      color: VisitDetailHelpers.statusColor(from),
                      fontSize: AppTheme.textBodyLarge,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              for (final option in options)
                _Option(
                  label: VisitDetailHelpers.statusActionLabel(from, option),
                  icon: VisitDetailHelpers.statusIcon(option),
                  color: option == VisitStatus.cancel
                      ? AppTheme.statOrange
                      : VisitDetailHelpers.statusColor(option),
                  selected: target == option,
                  error: DispatchRules.statusError(visit, option),
                  onTap: () => setState(() => _target = option),
                ),
              if (needsReason) ...[
                const SizedBox(height: 4),
                GWidgetTextField(
                  controller: _reason,
                  labelText: 'Reason',
                  maxLines: 2,
                  maxLength: VisitRules.maxReasonLength,
                  validator: (v) =>
                      VisitDetailHelpers.reasonError(v, required: true),
                ),
              ],
              const SizedBox(height: 12),
              GWidgetButton(
                text: 'Confirm',
                fontSize: AppTheme.textSubtitle,
                raduis: 14,
                isEnable: target != null &&
                    DispatchRules.statusError(visit, target) == null,
                isLoading: loading,
                loadingSize: 22,
                loadingStrokeWidth: 3,
                onPressed: () {
                  if (_form.currentState?.validate() != true) return;
                  context.read<DispatchBloc>().add(DispatchChangeStatusEvent(
                      changeVisitStatusParameters: ChangeVisitStatusParameters(
                          visitID: visit.id!,
                          status: target!,
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

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.error,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final String? error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = error == null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: enabled ? 1 : .55,
        child: Material(
          color: selected ? color.withValues(alpha: .12) : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: selected ? color : color.withValues(alpha: .3),
                    width: selected ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: AppTheme.font(
                                color: AppTheme.textPrimary,
                                fontSize: AppTheme.textBodyLarge,
                                fontWeight: FontWeight.w700)),
                        if (error != null)
                          Text(error!,
                              style: AppTheme.font(
                                  color: AppTheme.statOrange, fontSize: AppTheme.textCaption)),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle_rounded, color: color, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
