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
      (Icons.timer_off_rounded, 'Late visits', 'Start passed, not started',
          attention.late.length, AppTheme.statOrange),
      (Icons.person_search_rounded, 'Waiting for a technician',
          'Scheduled, nobody assigned', attention.needsTechnician.length,
          AppTheme.pending),
      (Icons.receipt_long_rounded, 'Ready to invoice',
          'Completed, invoice not issued', attention.readyToInvoice.length,
          AppTheme.primary),
      (Icons.request_quote_rounded, 'Overdue invoices', 'Owed after due date',
          attention.overdueInvoices.length, AppTheme.statOrange),
    ];

    return DashboardSection(
      title: 'Needs attention',
      subtitle: attention.total == 0
          ? 'Everything is on track'
          : '${attention.total} item${attention.total == 1 ? '' : 's'} to handle',
      actionText: 'Review',
      onAction: onOpen,
      child: attention.total == 0
          ? Row(
              children: [
                Icon(Icons.verified_rounded,
                    color: AppTheme.statGreen, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('No late visits, unassigned work or overdue '
                      'invoices right now.',
                      style: AppTheme.font(
                          color: AppTheme.textSecondary, fontSize: AppTheme.textBody)),
                ),
              ],
            )
          : Column(
              children: [
                for (final (icon, title, hint, count, color) in rows)
                  if (count > 0)
                    InkWell(
                      onTap: onOpen,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, size: 18, color: color),
                            ),
                            const SizedBox(width: 10),
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
                                          fontSize: AppTheme.textCaption)),
                                ],
                              ),
                            ),
                            Text('$count',
                                style: AppTheme.font(
                                    color: AppTheme.textPrimary,
                                    fontSize: AppTheme.textTitleLarge,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
    );
  }
}
