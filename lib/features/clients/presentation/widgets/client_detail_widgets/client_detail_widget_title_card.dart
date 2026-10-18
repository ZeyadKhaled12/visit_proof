import 'package:flutter/material.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';

class ClientDetailWidgetTitle extends StatelessWidget {
  const ClientDetailWidgetTitle(
      {super.key,
      required this.icon,
      this.onAdd,
      required this.title,
      this.addLoading = false});
  final String title;
  final IconData icon;
  final VoidCallback? onAdd;
  final bool addLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppFonts(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (onAdd != null)
              GWidgetButton(
                  text: '+ Add',
                  isLoading: addLoading,
                  loadingSize: 13,
                  fontSize: 13,
                  height: 32, // Reduced
                  width: 75,
                  paddingLeftRight: 0,
                  paddingTopBottom: 0,
                  backgroundColor: AppColors.primary,
                  raduis: 8,
                  onPressed: onAdd!),
          ],
        )
      ],
    );
  }
}
