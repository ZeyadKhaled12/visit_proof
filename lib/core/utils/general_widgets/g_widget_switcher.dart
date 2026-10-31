import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

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
                style: AppTheme.font(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.textBody,
                    fontWeight: FontWeight.w600)),
            if (subtitle != null)
              Text(subtitle!,
                  style:
                      AppTheme.font(color: AppTheme.textSecondary, fontSize: AppTheme.textCaption)),
          ],
        )),
        Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.secondary,
            inactiveTrackColor: AppTheme.locationChipBg,
            thumbColor: WidgetStateProperty.all(AppTheme.onPrimary)),
      ]);
}
