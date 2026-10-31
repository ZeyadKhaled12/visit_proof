import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';

/// Headline metric: value, change vs the previous period, tap for details.
class DashboardWidgetKpiCard extends StatelessWidget {
  const DashboardWidgetKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
    this.caption,
    this.footer,
    this.alert = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  /// Short context under the value, e.g. "of 24 due".
  final String? caption;

  /// Usually a [DashboardDelta].
  final Widget? footer;

  /// Tints the card when the value needs attention.
  final bool alert;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: alert ? color.withValues(alpha: .08) : AppTheme.cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: alert
                    ? color.withValues(alpha: .4)
                    : AppTheme.iconLightGrey.withValues(alpha: .25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.font(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.textSmall,
                            fontWeight: FontWeight.w700)),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppTheme.iconLightGrey),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value,
                    style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textDisplay,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.5)),
              ),
              if (caption != null)
                Text(caption!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        color: AppTheme.textSecondary, fontSize: AppTheme.textCaption)),
              if (footer != null) ...[const SizedBox(height: 6), footer!],
            ],
          ),
        ),
      ),
    );
  }
}
