import 'package:flutter/material.dart';

import 'package:visit_proof/core/utils/general_widgets/g_widget_button.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_text_field.dart';

import '../../../../core/utils/general_widgets/g_widget_bottom_sheet.dart';

class VisitDetailCommentSheet extends StatefulWidget {
  const VisitDetailCommentSheet({super.key});
  @override
  State<VisitDetailCommentSheet> createState() =>
      _VisitDetailCommentSheetState();
}

class _VisitDetailCommentSheetState extends State<VisitDetailCommentSheet> {
  final controller = TextEditingController();
  String? errorMsg;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GWidgetBottomSheet(
        title: 'Add admin comment',
        body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GWidgetTextField(
                  controller: controller,
                  errorMsg: errorMsg,
                  labelText: 'Comment',
                  maxLines: 4),
              const SizedBox(height: 17),
              GWidgetButton(
                  text: 'Add comment',
                  fontSize: 14,
                  onPressed: () {
                    if (controller.text.trim().length >= 2 &&
                        controller.text.trim().length <= 1000) {
                      Navigator.pop(context, controller.text.trim());
                    } else {
                      setState(() {
                        errorMsg = 'Comment must be more than 2 characters';
                      });
                    }
                  }),
            ]),
      );
}
