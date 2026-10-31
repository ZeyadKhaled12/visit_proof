import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';
import 'g_widget_menu_button.dart';

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
          // Opens the app menu when the screen sits inside it.
          const GWidgetMenuButton(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.font(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: AppTheme.textTitleLarge,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
      actions: actions);
}
