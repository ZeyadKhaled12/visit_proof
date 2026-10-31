import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

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
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary, // Header background, selected dates
              onPrimary: AppTheme.onPrimary, // Text on primary color
              surface: AppTheme.surface, // Background of the picker
              onSurface: AppTheme.textPrimary, // Default text color
            ),
            dialogBackgroundColor: AppTheme.surface,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    AppTheme.primary, // Button text colors (OK/CANCEL)
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
            colorScheme: ColorScheme.light(
              primary:
                  AppTheme.primary, // Clock hand, selected AM/PM background
              onPrimary: AppTheme.onPrimary, // Text on primary elements
              surface: AppTheme.surface, // Background of the dialog
              onSurface:
                  AppTheme.textPrimary, // Default text color (numbers, text)
              surfaceContainerHighest: AppTheme
                  .locationChipBg, // Background for unselected input fields/AM-PM
            ),
            dialogBackgroundColor: AppTheme.surface,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    AppTheme.primary, // Button text colors (OK/CANCEL)
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
