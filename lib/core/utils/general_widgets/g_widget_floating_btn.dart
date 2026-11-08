import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

class GWidgetFloatingBtn extends StatelessWidget {
  const GWidgetFloatingBtn(
      {super.key, required this.text, required this.onPressed, this.iconData});
  final String text;
  final IconData? iconData;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppTheme.primary,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: iconData == null ? null : Icon(iconData, color: AppTheme.onPrimary),
      label: Text(
        text,
        style: AppTheme.font(
          color: AppTheme.onPrimary,
          fontWeight: FontWeight.w700,
          fontSize: AppTheme.textSubtitle,
        ),
      ),
    );
  }
}
