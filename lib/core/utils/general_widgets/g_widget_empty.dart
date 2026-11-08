import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';
import 'g_widget_button.dart';

/// Friendly empty state: colored icon, message and an optional action.
class GWidgetEmpty extends StatelessWidget {
  const GWidgetEmpty({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withValues(alpha: .14),
            ),
            child: Icon(icon, size: 40, color: AppTheme.primary),
          ),
          const SizedBox(height: 18),
          Text(title,
              textAlign: TextAlign.center,
              style: AppTheme.font(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.textTitle,
                  fontWeight: FontWeight.w800)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!,
                textAlign: TextAlign.center,
                style: AppTheme.font(
                    color: AppTheme.textSecondary, fontSize: AppTheme.textBody, height: 1.4)),
          ],
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 20),
            GWidgetButton(
              text: actionText,
              fontSize: AppTheme.textBodyLarge,
              width: 210,
              height: 46,
              raduis: 14,
              paddingTopBottom: 0,
              onPressed: onAction!,
            ),
          ],
        ],
      ),
    );
  }
}
