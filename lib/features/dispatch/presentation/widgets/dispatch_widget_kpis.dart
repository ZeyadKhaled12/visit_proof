import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';

/// Four tappable counters that summarise the board at a glance.
class DispatchWidgetKpis extends StatelessWidget {
  const DispatchWidgetKpis({
    super.key,
    required this.unassigned,
    required this.conflicts,
    required this.late,
    required this.planned,
    required this.onUnassigned,
    required this.onConflicts,
    required this.onLate,
    required this.onPlanned,
  });

  final int unassigned;
  final int conflicts;
  final int late;
  final int planned;
  final VoidCallback onUnassigned;
  final VoidCallback onConflicts;
  final VoidCallback onLate;
  final VoidCallback onPlanned;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Kpi(
              label: 'Unassigned'.tr,
              value: unassigned,
              icon: Icons.inbox_rounded,
              color: AppTheme.pending,
              onTap: onUnassigned),
          const SizedBox(width: 8),
          _Kpi(
              label: 'Conflicts'.tr,
              value: conflicts,
              icon: Icons.warning_amber_rounded,
              color: AppTheme.statOrange,
              onTap: onConflicts),
          const SizedBox(width: 8),
          _Kpi(
              label: 'Late'.tr,
              value: late,
              icon: Icons.timer_off_rounded,
              color: AppTheme.primary,
              onTap: onLate),
          const SizedBox(width: 8),
          _Kpi(
              label: 'This day'.tr,
              value: planned,
              icon: Icons.event_available_rounded,
              color: AppTheme.statGreen,
              onTap: onPlanned),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = value > 0;

    return Expanded(
      child: Material(
        color: active ? color.withValues(alpha: .12) : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        size: 15, color: active ? color : AppTheme.iconLightGrey),
                    const SizedBox(width: 4),
                    Text('$value',
                        style: AppTheme.font(
                            color: active ? color : AppTheme.textLightHint,
                            fontSize: AppTheme.textTitle,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
                ),
                const SizedBox(height: 2),
                Text(label,
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
      ),
    );
  }
}
