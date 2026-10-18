import 'package:flutter/material.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';

class AddClientWidgetCardTitle extends StatelessWidget {
  const AddClientWidgetCardTitle(
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
              Icon(icon, color: AppColors.secondary, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppFonts(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.iconLightGrey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadowColor,
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
