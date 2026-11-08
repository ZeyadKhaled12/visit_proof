import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../domain/rules/dashboard_metrics.dart';
import 'dashboard_widget_parts.dart';

/// Top technicians of the period; tap one for their full results.
class DashboardWidgetTechnicians extends StatelessWidget {
  const DashboardWidgetTechnicians({
    super.key,
    required this.stats,
    required this.onTechnician,
    required this.onSeeAll,
    this.limit = 4,
  });

  final List<DashboardTechnicianStat> stats;
  final ValueChanged<String?> onTechnician;
  final VoidCallback onSeeAll;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final working = stats.where((s) => s.visits.isNotEmpty).toList();

    return DashboardSection(
      title: 'Technicians'.tr,
      subtitle: 'Completed visits in this period'.tr,
      actionText: working.isEmpty ? null : 'Compare'.tr,
      onAction: onSeeAll,
      child: working.isEmpty
          ? Text('No assigned visits in this period'.tr,
              style: AppTheme.font(color: AppTheme.textSecondary, fontSize: AppTheme.textBody))
          : Column(
              children: [
                for (final stat in working.take(limit))
                  _Row(stat: stat, onTap: () => onTechnician(stat.technician.id)),
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.stat, required this.onTap});
  final DashboardTechnicianStat stat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final technician = stat.technician;
    final rate = stat.completionRate;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            VisitDetailAvatar(
              letter: VisitDetailHelpers.initial(technician.name),
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(technician.name ?? 'Technician'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.font(
                                color: AppTheme.textPrimary,
                                fontSize: AppTheme.textBody,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                          '${stat.completed}/${stat.visits.length} · ${DashboardFormat.percent(rate)}',
                          style: AppTheme.font(
                              color: AppTheme.textSecondary,
                              fontSize: AppTheme.textSmall,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: rate ?? 0,
                      minHeight: 6,
                      backgroundColor: AppTheme.locationChipBg,
                      valueColor: AlwaysStoppedAnimation(AppTheme.statGreen),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
