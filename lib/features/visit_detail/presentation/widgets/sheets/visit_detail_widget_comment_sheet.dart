import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_text_field.dart';
import '../../../domain/rules/visit_rules.dart';
import '../../../domain/usecases/add_visit_comment_uc.dart';
import '../../controller/visit_detail_bloc.dart';
import '../visit_detail_widget_action_sheet.dart';

class VisitDetailWidgetCommentSheet extends StatefulWidget {
  const VisitDetailWidgetCommentSheet({super.key});

  @override
  State<VisitDetailWidgetCommentSheet> createState() =>
      _VisitDetailWidgetCommentSheetState();
}

class _VisitDetailWidgetCommentSheetState
    extends State<VisitDetailWidgetCommentSheet> {
  final _form = GlobalKey<FormState>();
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _submit(String visitID) {
    if (_form.currentState?.validate() != true) return;
    context.read<VisitDetailBloc>().add(AddVisitCommentEvent(
        addVisitCommentParameters: AddVisitCommentParameters(
            visitID: visitID, comment: _comment.text.trim())));
  }

  @override
  Widget build(BuildContext context) {
    return VisitDetailWidgetActionSheet(
      title: 'Add a note'.tr,
      subtitle: 'Notes are added to the visit activity log.'.tr,
      requestState: (state) => state.addCommentRequestState,
      builder: (context, state, loading) => Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GWidgetTextField(
              controller: _comment,
              labelText: 'Note'.tr,
              hintText: 'e.g., Client asked to call 30 minutes before arrival'.tr,
              maxLines: 4,
              maxLength: VisitRules.maxCommentLength,
              validator: (v) =>
                  (v?.trim().length ?? 0) < VisitRules.minCommentLength
                      ? 'Write at least {0} characters'.trArgs([VisitRules.minCommentLength])
                      : null,
            ),
            const SizedBox(height: 16),
            GWidgetButton(
              text: 'Add note'.tr,
              fontSize: AppTheme.textSubtitle,
              raduis: 14,
              isLoading: loading,
              loadingSize: 22,
              loadingStrokeWidth: 3,
              onPressed: () => _submit(state.visit.id!),
            ),
          ],
        ),
      ),
    );
  }
}
