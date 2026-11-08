import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_theme.dart';

class InvDetailWidgetInfoLine extends StatelessWidget {
  const InvDetailWidgetInfoLine({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTheme.font(
                  fontSize: AppTheme.textBody,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: AppTheme.font(
                  fontSize: emphasize ? AppTheme.textTitle : AppTheme.textBody,
                  color: valueColor ?? AppTheme.textPrimary,
                  fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
}

class InvDetailWidgetPanel extends StatelessWidget {
  const InvDetailWidgetPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.iconLightGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.font(
                      fontSize: AppTheme.textSubtitle,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
}

class InvDetailWidgetBadge extends StatelessWidget {
  const InvDetailWidgetBadge({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .11),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          text,
          style: AppTheme.font(
            fontSize: AppTheme.textSmall,
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}
