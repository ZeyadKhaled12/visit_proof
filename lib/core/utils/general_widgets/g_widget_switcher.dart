import 'package:flutter/material.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';

class GWidgetSwitcher extends StatelessWidget {
  const GWidgetSwitcher(
      {super.key,
      required this.title,
      required this.value,
      required this.onChanged,
      this.subtitle});
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: AppFonts(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            if (subtitle != null)
              Text(subtitle!,
                  style:
                      AppFonts(color: AppColors.textSecondary, fontSize: 11)),
          ],
        )),
        Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.secondary,
            inactiveTrackColor: AppColors.locationChipBg,
            thumbColor: WidgetStateProperty.all(AppColors.surfaceWhite)),
      ]);
}
