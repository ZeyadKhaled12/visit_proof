import 'package:flutter/material.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';

class GWidgetExcel extends StatelessWidget {
  const GWidgetExcel({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: AppColors.excelGreen.withValues(alpha: .2)),
        ),
        child: Row(
          children: [
            Text(
              "Excel",
              style: AppFonts(
                color: AppColors.textPrimary.withValues(alpha: .9),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.download, size: 16, color: AppColors.excelGreen),
          ],
        ),
      ),
    );
  }
}
