import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../domain/rules/dispatch_rules.dart';

/// Preview of a batch plan: visit → technician at time, or why it can't go.
class DispatchWidgetPlanPreview extends StatelessWidget {
  const DispatchWidgetPlanPreview({super.key, required this.plans});
  final List<PlannedAssignment> plans;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (final plan in plans) _PlanRow(plan: plan)],
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.plan});
  final PlannedAssignment plan;

  @override
  Widget build(BuildContext context) {
    final color = !plan.ok
        ? AppTheme.statOrange
        : plan.warnings.isNotEmpty
            ? AppTheme.pending
            : AppTheme.statGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${plan.visit.visitNumber ?? 'Visit'} · '
                    '${plan.visit.serviceName ?? 'No service'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textBody,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                    plan.ok
                        ? '{0} at {1}{2}'.trArgs([plan.technician!.name ?? 'Technician'.tr, VisitDetailHelpers.time(plan.start), plan.warnings.isEmpty ? '' : ' · ${plan.warnings.first.message}'])
                        : plan.problem ?? 'No technician is available.'.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        color: color, fontSize: AppTheme.textSmall, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Icon(
            !plan.ok
                ? Icons.block
                : plan.warnings.isNotEmpty
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_rounded,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }
}
