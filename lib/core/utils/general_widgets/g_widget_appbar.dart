import 'package:flutter/material.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';

class GWidgetAppbar {
  final String title;
  final IconData icon;
  final List<Widget>? actions;

  GWidgetAppbar({required this.title, required this.icon, this.actions});
  AppBar appbar() => AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 60,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: AppFonts(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: actions);
}
