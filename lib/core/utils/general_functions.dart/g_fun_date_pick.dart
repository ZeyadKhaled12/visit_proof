import 'package:flutter/material.dart';

import '../../../configs/app_colors.dart';

class GFunDatePick {
  static Future<DateTime?> showCustomDatePicker(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime now = DateTime.now();

    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary, // Header background, selected dates
              onPrimary: AppColors.surfaceWhite, // Text on primary color
              surface: AppColors.surfaceWhite, // Background of the picker
              onSurface: AppColors.textPrimary, // Default text color
            ),
            dialogBackgroundColor: AppColors.surfaceWhite,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    AppColors.primary, // Button text colors (OK/CANCEL)
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  static Future<TimeOfDay?> showCustomTimePicker(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary:
                  AppColors.primary, // Clock hand, selected AM/PM background
              onPrimary: AppColors.surfaceWhite, // Text on primary elements
              surface: AppColors.surfaceWhite, // Background of the dialog
              onSurface:
                  AppColors.textPrimary, // Default text color (numbers, text)
              surfaceContainerHighest: AppColors
                  .locationChipBg, // Background for unselected input fields/AM-PM
            ),
            dialogBackgroundColor: AppColors.surfaceWhite,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    AppColors.primary, // Button text colors (OK/CANCEL)
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
