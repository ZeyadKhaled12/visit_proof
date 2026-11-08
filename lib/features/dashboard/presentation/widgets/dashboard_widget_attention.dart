import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../domain/rules/dashboard_metrics.dart';
import 'dashboard_widget_parts.dart';

/// What needs the admin now. Each row is a real rule with a count; the
/// whole panel opens the detailed lists.
class DashboardWidgetAttention extends StatelessWidget {
  const DashboardWidgetAttention(
      {super.key, required this.attention, required this.onOpen});
  final DashboardAttention attention;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.timer_off_rounded, 'Late visits'.tr, 'Start passed, not started'.tr,
          attention.late.length, AppTheme.statOrange),
      (Icons.person_search_rounded, 'Waiting for a technician'.tr,
          'Scheduled, nobody assigned'.tr, attention.needsTechnician.length,
          AppTheme.pending),
      (Icons.receipt_long_rounded, 'Ready to invoice'.tr,
          'Completed, invoice not issued'.tr, attention.readyToInvoice.length,
          AppTheme.primary),
      (Icons.request_quote_rounded, 'Overdue invoices'.tr, 'Owed after due date'.tr,
          attention.overdueInvoices.length, AppTheme.statOrange),
    ].where((row) => row.$4 > 0).toList();

    return DashboardSection(
      title: 'Needs attention'.tr,
      subtitle: attention.total == 0
          ? 'Everything is on track'.tr
          : '{0} item{1} to handle'.trArgs([attention.total, attention.total == 1 ? '' : 's']),
      actionText: 'Review'.tr,
      onAction: onOpen,
      borderColor: attention.total == 0
          ? null
          : AppTheme.statOrange.withValues(alpha: .35),
      child: attention.total == 0
          ? Row(
              children: [
                Icon(Icons.verified_rounded,
                    color: AppTheme.statGreen, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('No late visits, unassigned work or overdue invoices right now.'.tr,
                      style: AppTheme.font(
                          color: AppTheme.textSecondary, fontSize: AppTheme.textBody)),
                ),
              ],
            )
          : Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: AppTheme.iconLightGrey),
                  _Row(row: rows[i], onTap: onOpen),
                ],
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row, required this.onTap});
  final (IconData, String, String, int, Color) row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, title, hint, count, color) = row;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTheme.font(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.textBody,
                          fontWeight: FontWeight.w700)),
                  Text(hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.font(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.textSmall)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('$count',
                style: AppTheme.font(
                    color: color,
                    fontSize: AppTheme.textTitleLarge,
                    fontWeight: FontWeight.w800)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                size: 22, color: AppTheme.iconGrey),
          ],
        ),
      ),
    );
  }
}
