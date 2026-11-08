import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/dashboard_metrics.dart';
import 'dashboard_widget_parts.dart';

/// Today's visits by workflow stage. Each stage is labeled with a word and
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
      title: "Today's operations".tr,
      subtitle: today.isEmpty
          ? 'No visits planned for today'.tr
          : '{0} visit{1} today'.trArgs([today.length, today.length == 1 ? '' : 's']),
      actionText: today.isEmpty ? null : 'All'.tr,
      onAction: () => onStage(null),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _stages.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: _Stage(
                  status: _stages[i],
                  count: counts[_stages[i]]!,
                  onTap: () => onStage(_stages[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({required this.status, required this.count, required this.onTap});
  final VisitStatus status;
  final int count;
  final VoidCallback onTap;

  /// Several words may wrap; a single word shrinks instead of breaking.
  Widget _label(String text, Color color) {
    final label = Text(text,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.font(
            color: color,
            fontSize: AppTheme.textMicro,
            fontWeight: FontWeight.w700,
            height: 1.15));
    return text.contains(' ')
        ? label
        : FittedBox(fit: BoxFit.scaleDown, child: label);
  }

  @override
  Widget build(BuildContext context) {
    final color = VisitDetailHelpers.statusColor(status);
    final active = count > 0;
    final foreground = active ? color : AppTheme.textDarkHint;

    return Material(
      color: active ? color.withValues(alpha: .10) : AppTheme.locationChipBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          child: Column(
            children: [
              Text('$count',
                  style: AppTheme.font(
                      color: foreground,
                      fontSize: AppTheme.textTitleLarge,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              _label(VisitDetailHelpers.statusText(status), foreground),
            ],
          ),
        ),
      ),
    );
  }
}
