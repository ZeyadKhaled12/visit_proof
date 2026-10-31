import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/visit_rules.dart';
import 'sheets/visit_detail_widget_service_sheet.dart';
import 'visit_detail_helpers.dart';
import 'visit_detail_widget_action_sheet.dart';
import 'visit_detail_widget_parts.dart';

class VisitDetailWidgetService extends StatelessWidget {
  const VisitDetailWidgetService(
      {super.key, required this.visit, required this.invoice});
  final VisitDetailModel visit;
  final InvoiceDetailModel? invoice;

  @override
  Widget build(BuildContext context) {
    final tasks = visit.checkList ?? const [];
    final before = visit.requireBeforeWorkPhotos ?? false;
    final after = visit.requireAfterWorkPhotos ?? false;

    return VisitDetailSection(
      title: 'Service',
      icon: Icons.build_circle_rounded,
      color: AppTheme.primary,
      actionText: 'Change',
      actionIcon: Icons.swap_horiz_rounded,
      onAction: VisitRules.canChangeService(visit, invoice)
          ? () => VisitDetailWidgetActionSheet.show(
              context, VisitDetailWidgetServiceSheet(visit: visit))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visit.serviceName ?? 'No service selected',
                        style: AppTheme.font(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.textSubtitle,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    VisitDetailPill(
                        text: visit.category?.name ?? 'Uncategorized',
                        color: AppTheme.primary,
                        icon: Icons.category_rounded),
                  ],
                ),
              ),
              Text(
                  visit.price == null
                      ? '—'
                      : VisitDetailHelpers.money(visit.price),
                  style: AppTheme.font(
                      color: AppTheme.statGreen,
                      fontSize: AppTheme.textTitle,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          if (tasks.isEmpty)
            const VisitDetailEmpty(
                icon: Icons.checklist_rounded, text: 'No checklist tasks')
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.locationChipBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Checklist · ${tasks.length} tasks',
                      style: AppTheme.font(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.textSmall,
                          fontWeight: FontWeight.w800)),
                  for (final task in tasks)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 16, color: AppTheme.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(task,
                                style: AppTheme.font(
                                    color: AppTheme.textDarkHint,
                                    fontSize: AppTheme.textBody)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (before)
                VisitDetailPill(
                    text: 'Before photos required',
                    color: AppTheme.secondary,
                    icon: Icons.photo_camera_rounded),
              if (after)
                VisitDetailPill(
                    text: 'After photos required',
                    color: AppTheme.statGreen,
                    icon: Icons.photo_camera_back_rounded),
              if (!before && !after)
                VisitDetailPill(
                    text: 'No photo proof required',
                    color: AppTheme.iconGrey,
                    icon: Icons.no_photography_rounded),
            ],
          ),
        ],
      ),
    );
  }
}
