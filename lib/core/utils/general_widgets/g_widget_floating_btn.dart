import 'dart:ui';

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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.fabShadowColor,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: .5),
                  AppTheme.secondary.withValues(alpha: .5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: FloatingActionButton.extended(
              onPressed: onPressed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              highlightElevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              icon:
                  iconData == null ? null : Icon(iconData, color: AppTheme.onPrimary),
              label: Text(
                text,
                style: AppTheme.font(
                  color: AppTheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.textSubtitle,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
