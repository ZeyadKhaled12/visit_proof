import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../../visit_detail/domain/rules/visit_rules.dart';
import '../../../../visit_detail/domain/usecases/unassign_technician_uc.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../controller/dispatch_bloc.dart';
import '../dispatch_widget_action_sheet.dart';

/// Sends a visit back to the queue.
class DispatchWidgetUnassignSheet extends StatefulWidget {
  const DispatchWidgetUnassignSheet({super.key, required this.visitID});
  final String? visitID;

  @override
  State<DispatchWidgetUnassignSheet> createState() =>
      _DispatchWidgetUnassignSheetState();
}

class _DispatchWidgetUnassignSheetState
    extends State<DispatchWidgetUnassignSheet> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DispatchWidgetActionSheet(
      title: 'Unassign technician',
      requestState: (state) => state.unassignRequestState,
      builder: (context, state, loading) {
        final visit = state.visitById(widget.visitID);
        if (visit == null) {
          return const VisitDetailEmpty(
              icon: Icons.search_off_rounded,
              text: 'This visit is no longer available');
        }

        return Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VisitDetailNotice(
                text: '${visit.visitNumber ?? 'The visit'} goes back to the '
                    'queue and ${visit.technicianModel?.name ?? 'the technician'} '
                    'is free at ${VisitDetailHelpers.time(visit.startDate)}.',
                color: AppTheme.pending,
              ),
              const SizedBox(height: 14),
              GWidgetTextField(
                controller: _reason,
                labelText: 'Reason (optional)',
                maxLines: 2,
                maxLength: VisitRules.maxReasonLength,
                validator: (v) =>
                    VisitDetailHelpers.reasonError(v, required: false),
              ),
              const SizedBox(height: 12),
              GWidgetButton(
                text: 'Unassign',
                fontSize: AppTheme.textSubtitle,
                raduis: 14,
                backgroundColor: AppTheme.statOrange,
                isLoading: loading,
                loadingSize: 22,
                loadingStrokeWidth: 3,
                onPressed: () {
                  if (_form.currentState?.validate() != true) return;
                  context.read<DispatchBloc>().add(DispatchUnassignEvent(
                      unassignTechnicianParameters:
                          UnassignTechnicianParameters(
                              visitID: visit.id!,
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
