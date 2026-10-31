import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

class GWidgetNaviAppbar {
  static AppBar appBar(BuildContext context, String title) => AppBar(
      systemOverlayStyle: AppTheme.systemOverlayOnPrimary,
      backgroundColor: AppTheme.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(color: AppTheme.onPrimary),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: AppTheme.scaffoldBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  color: AppTheme.textPrimary, size: 20),
            ),
          ),
          Text(
            title,
            style: AppTheme.font(
              color: AppTheme.onPrimary,
              fontSize: AppTheme.textTitleLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox()
        ],
      ),
      centerTitle: true);
}
