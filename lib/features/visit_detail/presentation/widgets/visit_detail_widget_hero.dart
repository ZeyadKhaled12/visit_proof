import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/payment_status_enum.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/visit_rules.dart';
import 'visit_detail_helpers.dart';
import 'visit_detail_widget_parts.dart';

/// Header card: visit number, service, key figures and workflow progress.
class VisitDetailWidgetHero extends StatelessWidget {
  const VisitDetailWidgetHero({super.key, required this.visit});
  final VisitDetailModel visit;

  @override
  Widget build(BuildContext context) {
    final status = VisitRules.statusOf(visit);
    final cancelled = status == VisitStatus.cancel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border.all(color: AppTheme.iconLightGrey),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 8,
            children: [
              _GlassChip(
                  icon: Icons.tag_rounded, text: visit.visitNumber ?? 'Visit'.tr),
              VisitDetailPill(
                text: VisitDetailHelpers.statusText(status),
                color: VisitDetailHelpers.statusColor(status),
                icon: VisitDetailHelpers.statusIcon(status),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            (visit.serviceName ?? '').trim().isEmpty
                ? 'No service selected'.tr
                : visit.serviceName!,
            style: AppTheme.font(
                color: AppTheme.textPrimary,
                fontSize: AppTheme.textHeadline,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.category_rounded,
                  size: 14,
                  color: AppTheme.textSecondary),
              const SizedBox(width: 5),
              Text(visit.category?.name?.tr ?? 'Uncategorized'.tr,
                  style: AppTheme.font(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.textBody,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _GlassStat(
                    label: 'Price'.tr,
                    value: visit.price == null
                        ? '—'
                        : VisitDetailHelpers.money(visit.price)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GlassStat(
                    label: 'Priority'.tr,
                    value: VisitDetailHelpers.priorityText(visit.priority)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GlassStat(
                    label: 'Payment'.tr,
                    value: VisitDetailHelpers.capitalize(PaymentStatusSwitch(
                            paymentStatusEnum: visit.paymentStatus)
                        .getText())),
              ),
            ],
          ),
          const SizedBox(height: 20),
          cancelled
              ? const _CancelledBanner()
              : _WorkflowProgress(current: status),
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.locationChipBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textPrimary),
          const SizedBox(width: 4),
          Text(text,
              style: AppTheme.font(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.textSmall,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0)),
        ],
      ),
    );
  }
}

class _GlassStat extends StatelessWidget {
  const _GlassStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.locationChipBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTheme.font(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.textCaption,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.font(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.textBody,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

/// Six dots, one per workflow step, filled up to the current status.
class _WorkflowProgress extends StatelessWidget {
  const _WorkflowProgress({required this.current});
  final VisitStatus current;

  static List<String> get _labels => ['Draft'.tr, 'Scheduled'.tr, 'Assigned'.tr, 'On way'.tr, 'Work'.tr, 'Done'.tr];

  @override
  Widget build(BuildContext context) {
    final currentIndex = VisitRules.workflow.indexOf(current);
    final steps = VisitRules.workflow.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps, (index) {
        final reached = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _line(visible: index > 0, on: reached)),
                  Container(
                    width: isCurrent ? 22 : 16,
                    height: isCurrent ? 22 : 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: reached
                          ? AppTheme.primary
                          : AppTheme.iconLightGrey,
                      border: isCurrent
                          ? Border.all(
                              color: AppTheme.primarySoft,
                              width: 4,
                              strokeAlign: BorderSide.strokeAlignOutside)
                          : null,
                    ),
                    child: reached && !isCurrent
                        ? Icon(Icons.check_rounded,
                            size: 11, color: AppTheme.onPrimary)
                        : null,
                  ),
                  Expanded(
                      child: _line(
                          visible: index < steps - 1, on: index < currentIndex)),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(_labels[index],
                  textAlign: TextAlign.center,
                  style: AppTheme.font(
                      color: reached ? AppTheme.textPrimary : AppTheme.textDarkHint,
                      fontSize: AppTheme.textMicro,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _line({required bool visible, required bool on}) => Container(
        height: 3,
        color: !visible
            ? Colors.transparent
            : on
                ? AppTheme.primary
                : AppTheme.iconLightGrey,
      );
}

class _CancelledBanner extends StatelessWidget {
  const _CancelledBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.statOrange.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.block_rounded,
              color: AppTheme.statOrange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text('This visit was cancelled and is out of the workflow.'.tr,
                style: AppTheme.font(
                    color: AppTheme.statOrange,
                    fontSize: AppTheme.textSmall,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
