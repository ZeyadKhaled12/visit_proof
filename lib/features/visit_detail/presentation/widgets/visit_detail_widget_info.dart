import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/visit_rules.dart';
import 'sheets/visit_detail_widget_info_sheet.dart';
import 'visit_detail_helpers.dart';
import 'visit_detail_widget_action_sheet.dart';
import 'visit_detail_widget_parts.dart';

class VisitDetailWidgetInfo extends StatelessWidget {
  const VisitDetailWidgetInfo({super.key, required this.visit});
  final VisitDetailModel visit;

  @override
  Widget build(BuildContext context) {
    return VisitDetailSection(
      title: 'Job Notes'.tr,
      icon: Icons.sticky_note_2_rounded,
      color: AppTheme.statOrange,
      actionText: 'Edit'.tr,
      onAction: VisitRules.canEditInfo(visit)
          ? () => VisitDetailWidgetActionSheet.show(
              context, VisitDetailWidgetInfoSheet(visit: visit))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Priority'.tr,
                  style: AppTheme.font(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.textBody,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              VisitDetailPill(
                text: VisitDetailHelpers.priorityText(visit.priority),
                color: VisitDetailHelpers.priorityColor(visit.priority),
                icon: Icons.local_fire_department_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          VisitDetailTextBlock(
              title: 'Problem'.tr,
              text: visit.problemDescription,
              color: AppTheme.statOrange),
          const SizedBox(height: 10),
          VisitDetailTextBlock(
              title: 'Notes for the technician'.tr,
              text: visit.notes,
              color: AppTheme.primary),
        ],
      ),
    );
  }
}
