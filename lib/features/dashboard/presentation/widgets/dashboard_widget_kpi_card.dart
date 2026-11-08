import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';

/// Headline metric: value, change vs the previous period, tap for details.
class DashboardWidgetKpiCard extends StatelessWidget {
  const DashboardWidgetKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.unit,
    this.caption,
    this.footer,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  /// Shown small after the value, e.g. "%" or " SAR".
  final String? unit;

  /// Short context under the value, e.g. "of 24 due".
  final String? caption;

  /// Usually a [DashboardDelta].
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.iconLightGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.font(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.textSmall,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: value,
                      style: AppTheme.font(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.textDisplay,
                          fontWeight: FontWeight.w800)),
                  if (unit != null)
                    TextSpan(
                        text: unit,
                        style: AppTheme.font(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.textSmall,
                            fontWeight: FontWeight.w700)),
                ])),
              ),
              if (caption != null) ...[
                const SizedBox(height: 2),
                Text(caption!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        color: AppTheme.textDarkHint,
                        fontSize: AppTheme.textCaption)),
              ],
              if (footer != null) ...[const SizedBox(height: 8), footer!],
            ],
          ),
        ),
      ),
    );
  }
}
