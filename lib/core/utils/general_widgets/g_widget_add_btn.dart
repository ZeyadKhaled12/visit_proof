import 'package:flutter/material.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';

class GWidgetAddBtn extends StatelessWidget {
  const GWidgetAddBtn({super.key, required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: AppColors.secondary,
        splashColor: AppColors.secondary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
            SizedBox(width: 5),
            Text(text,
                style: AppFonts(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}
