import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';
import 'g_widget_tour.dart';

class GWidgetNaviAppbar {
  static AppBar appBar(BuildContext context, String title) => AppBar(
      systemOverlayStyle: AppTheme.systemOverlay,
      backgroundColor: AppTheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      shape: Border(bottom: BorderSide(color: AppTheme.iconLightGrey)),
      automaticallyImplyLeading: false,
      titleSpacing: 8,
      title: Row(
        children: [
          IconButton(
            tooltip: 'Back'.tr,
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary, size: 22),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.font(
                color: AppTheme.textPrimary,
                fontSize: AppTheme.textTitleLarge,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      actions: const [GWidgetTourFlagSpace()]);
}
