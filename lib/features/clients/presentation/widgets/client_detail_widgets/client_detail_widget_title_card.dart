import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../../configs/app_theme.dart';
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
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: AppTheme.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTheme.font(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.textTitleLarge,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (onAdd != null)
              GWidgetButton(
                  text: '+ Add'.tr,
                  isLoading: addLoading,
                  loadingSize: 13,
                  fontSize: AppTheme.textBody,
                  height: 32, // Reduced
                  width: 75,
                  paddingLeftRight: 0,
                  paddingTopBottom: 0,
                  backgroundColor: AppTheme.primary,
                  raduis: 8,
                  onPressed: onAdd!),
          ],
        )
      ],
    );
  }
}
