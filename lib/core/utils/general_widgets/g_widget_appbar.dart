import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';
import 'g_widget_menu_button.dart';
import 'g_widget_tour.dart';

class GWidgetAppbar {
  final String title;
  final List<Widget>? actions;

  GWidgetAppbar({required this.title, this.actions});
  AppBar appbar() => AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppTheme.surface,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 64,
      shape: Border(bottom: BorderSide(color: AppTheme.iconLightGrey)),
      // The menu button below doubles as the back button.
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Opens the app menu, or goes back on a screen opened on top.
          const GWidgetMenuButton(),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.font(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: AppTheme.textTitleLarge,
              ),
            ),
          ),
        ],
      ),
      actions: [...?actions, const GWidgetTourFlagSpace()]);
}
