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
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 22),
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
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: AppTheme.iconLightGrey),
          ),
          child: child,
        )
      ],
    );
  }
}
