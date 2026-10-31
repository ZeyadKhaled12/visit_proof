import 'package:flutter/material.dart';
import 'package:visit_proof/app/app.dart';
import 'package:visit_proof/configs/app_theme.dart';

import '../core/utils/general_widgets/g_widget_button.dart';

class AppToasts {
  static Future<void> showMessage(String message,
      {bool isError = false, Color? color}) async {
    ScaffoldMessenger.of(App.navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        backgroundColor:
            color ?? (isError ? AppTheme.statOrange : AppTheme.statGreen),
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: AppTheme.font(
              color: AppTheme.onPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static Future<dynamic> showBottomSheet(
      BuildContext context, Widget bottomSheet) async {
    return await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => bottomSheet);
  }

  static Future<dynamic> showDeleteConfirmation(
      {String? headTitle, required String title}) async {
    return await showDialog(
      context: App.navigatorKey.currentContext!,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: headTitle == null
            ? null
            : Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppTheme.statOrange, size: 24),
                  const SizedBox(width: 8),
                  Text(headTitle,
                      style: AppTheme.font(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: AppTheme.textTitleLarge)),
                ],
              ),
        content: Text(
          title,
          style: AppTheme.font(
              color: AppTheme.textSecondary, fontSize: AppTheme.textBodyLarge, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTheme.font(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.bold)),
          ),
          GWidgetButton(
            text: 'Delete',
            width: 90,
            height: 38,
            paddingTopBottom: 0,
            backgroundColor: AppTheme.statOrange,
            raduis: 10,
            onPressed: () {
              Navigator.pop(ctx, true);
            },
          ),
        ],
      ),
    );
  }
}
