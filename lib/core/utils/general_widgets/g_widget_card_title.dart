import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

class GWidgetCardTitle extends StatelessWidget {
  const GWidgetCardTitle(
      {super.key,
      required this.icon,
      required this.title,
      required this.child});
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.secondary, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.font(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.textTitleLarge,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppTheme.iconLightGrey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cardShadowColor,
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        )
      ],
    );
  }
}
