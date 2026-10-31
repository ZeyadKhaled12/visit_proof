import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/visit_rules.dart';
import 'sheets/visit_detail_widget_assign_sheet.dart';
import 'sheets/visit_detail_widget_status_sheet.dart';
import 'visit_detail_helpers.dart';
import 'visit_detail_widget_action_sheet.dart';
import 'visit_detail_widget_parts.dart';

/// "What happens next" card: the moves allowed from the current status.
class VisitDetailWidgetWorkflow extends StatelessWidget {
  const VisitDetailWidgetWorkflow(
      {super.key, required this.visit, required this.invoice});
  final VisitDetailModel visit;
  final InvoiceDetailModel? invoice;

  void _openStatusSheet(BuildContext context, VisitStatus target) {
    VisitDetailWidgetActionSheet.show(
        context,
        VisitDetailWidgetStatusSheet(
            visit: visit, invoice: invoice, target: target));
  }

  @override
  Widget build(BuildContext context) {
    final status = VisitRules.statusOf(visit);
    final color = VisitDetailHelpers.statusColor(status);
    final next = VisitRules.nextStatuses(status);
    final moves = next.where((e) => e != VisitStatus.cancel).toList();
    final needsTechnician =
        VisitRules.canAssignTechnician(visit) && visit.technicianModel == null;

    return VisitDetailSection(
      title: 'Next Step',
      icon: Icons.route_rounded,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(VisitDetailHelpers.statusIcon(status),
                  color: color, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Currently ${VisitDetailHelpers.statusText(status)}',
                        style: AppTheme.font(
                            color: color,
                            fontSize: AppTheme.textSubtitle,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(VisitDetailHelpers.statusHint(status),
                        style: AppTheme.font(
                            color: AppTheme.textSecondary, fontSize: AppTheme.textSmall)),
                  ],
                ),
              ),
            ],
          ),
          if (needsTechnician) ...[
            const SizedBox(height: 14),
            _MoveButton(
              label: 'Assign technician',
              icon: Icons.engineering_rounded,
              color: AppTheme.primary,
              filled: true,
              onPressed: () => VisitDetailWidgetActionSheet.show(
                  context, VisitDetailWidgetAssignSheet(visit: visit)),
            ),
          ],
          for (final target in moves) ...[
            const SizedBox(height: 10),
            _MoveButton(
              label: VisitDetailHelpers.statusActionLabel(status, target),
              icon: VisitDetailHelpers.statusIcon(target),
              color: VisitDetailHelpers.statusColor(target),
              filled: VisitRules.isForward(status, target),
              onPressed: () => _openStatusSheet(context, target),
            ),
          ],
          if (next.contains(VisitStatus.cancel)) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () => _openStatusSheet(context, VisitStatus.cancel),
                icon: Icon(Icons.cancel_outlined,
                    size: 18, color: AppTheme.statOrange),
                label: Text('Cancel visit',
                    style: AppTheme.font(
                        color: AppTheme.statOrange,
                        fontSize: AppTheme.textBody,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
          if (next.isEmpty) ...[
            const SizedBox(height: 14),
            VisitDetailNotice(
              text: 'This visit has reached the end of its workflow.',
              color: AppTheme.statGreen,
              icon: Icons.verified_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _MoveButton extends StatelessWidget {
  const _MoveButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppTheme.surface : color;

    return GWidgetButton(
      height: 48,
      raduis: 14,
      fontSize: AppTheme.textSubtitle,
      text: label,
      colorText: foreground,
      gradient: filled
          ? LinearGradient(colors: [color, color.withValues(alpha: .75)])
          : null,
      backgroundColor: filled ? color : color.withValues(alpha: .08),
      border: filled ? null : Border.all(color: color.withValues(alpha: .6)),
      boxShadow: filled
          ? [
              BoxShadow(
                  color: color.withValues(alpha: .3),
                  blurRadius: 12,
                  offset: const Offset(0, 5))
            ]
          : null,
      widget: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(icon, color: foreground, size: 20),
      ),
      onPressed: onPressed,
    );
  }
}
