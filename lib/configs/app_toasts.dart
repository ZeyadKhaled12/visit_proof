import 'package:flutter/material.dart';
import 'package:visit_proof/app/app.dart';
import 'package:visit_proof/configs/app_colors.dart';
import 'package:visit_proof/configs/app_fonts.dart';

import '../core/utils/general_widgets/g_widget_button.dart';

class AppToasts {
  static Future<void> showMessage(String message,
      {bool isError = false}) async {
    ScaffoldMessenger.of(App.navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.statOrange : AppColors.statGreen,
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: AppFonts(
              color: AppColors.surfaceWhite, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static Future<dynamic> showDeleteConfirmation(
      {String? headTitle, required String title}) async {
    return await showDialog(
      context: App.navigatorKey.currentContext!,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: headTitle == null
            ? null
            : Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.statOrange, size: 24),
                  const SizedBox(width: 8),
                  Text(headTitle,
                      style: AppFonts(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
        content: Text(
          title,
          style: AppFonts(
              color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppFonts(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold)),
          ),
          GWidgetButton(
            text: 'Delete',
            width: 90,
            height: 38,
            paddingTopBottom: 0,
            backgroundColor: AppColors.statOrange,
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
