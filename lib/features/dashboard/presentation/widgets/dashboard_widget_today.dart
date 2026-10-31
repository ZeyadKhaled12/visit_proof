import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/dashboard_metrics.dart';
import 'dashboard_widget_parts.dart';

/// Today's visits by workflow stage. Each stage is labeled with an icon and
/// a count, so it reads without relying on color.
class DashboardWidgetToday extends StatelessWidget {
  const DashboardWidgetToday({
    super.key,
    required this.visits,
    required this.onStage,
  });

  /// All visits; today's are picked here.
  final List<VisitDetailModel> visits;
  final ValueChanged<VisitStatus?> onStage;

  static const _stages = [
    VisitStatus.scheduled,
    VisitStatus.assigned,
    VisitStatus.onWay,
    VisitStatus.inProgress,
    VisitStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final today = DashboardMetrics.today(visits, DateTime.now());
    final counts = DashboardMetrics.statusCounts(today);

    return DashboardSection(
      title: "Today's operations",
      subtitle: today.isEmpty
          ? 'No visits planned for today'
          : '${today.length} visit${today.length == 1 ? '' : 's'} today',
      actionText: today.isEmpty ? null : 'All',
      onAction: () => onStage(null),
      child: LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 420 ? 5 : 3;
        return DashboardGrid(
          columns: columns,
          spacing: 8,
          children: [
            for (final stage in _stages)
              _Stage(
                status: stage,
                count: counts[stage]!,
                onTap: () => onStage(stage),
              ),
          ],
        );
      }),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({required this.status, required this.count, required this.onTap});
  final VisitStatus status;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = VisitDetailHelpers.statusColor(status);
    final active = count > 0;

    return Material(
      color: active ? color.withValues(alpha: .10) : AppTheme.locationChipBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            children: [
              Icon(VisitDetailHelpers.statusIcon(status),
                  size: 18, color: active ? color : AppTheme.iconLightGrey),
              const SizedBox(height: 4),
              Text('$count',
                  style: AppTheme.font(
                      color: active ? AppTheme.textPrimary : AppTheme.textLightHint,
                      fontSize: AppTheme.textTitleLarge,
                      fontWeight: FontWeight.w800)),
              Text(VisitDetailHelpers.statusText(status),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.font(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.textMicro,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
