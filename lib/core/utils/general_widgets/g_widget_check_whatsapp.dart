import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';
import '../assets_manager.dart';

class GWidgetCheckWhatsapp extends StatelessWidget {
  const GWidgetCheckWhatsapp(
      {super.key, required this.onPressed, required this.hasWhatsapp});
  final Function() onPressed;
  final bool hasWhatsapp;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: hasWhatsapp
              ? AppTheme.whatsappGreen.withValues(alpha: 0.1)
              : AppTheme.locationChipBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasWhatsapp
                ? AppTheme.whatsappGreen
                : AppTheme.iconLightGrey.withValues(alpha: 0.5),
            width: hasWhatsapp ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: hasWhatsapp
                    ? Image(
                        image: AssetImage(IconAsset.whatsapp),
                        color: AppTheme.whatsappGreen,
                        width: 26,
                        height: 26)
                    : Image(
                        image: AssetImage(IconAsset.whatsapp),
                        color: AppTheme.iconGrey,
                        width: 26,
                        height: 26)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Number includes WhatsApp',
                style: AppTheme.font(
                  color: hasWhatsapp
                      ? AppTheme.whatsappGreen
                      : AppTheme.textDarkHint,
                  fontWeight: hasWhatsapp ? FontWeight.bold : FontWeight.w500,
                  fontSize: AppTheme.textSubtitle,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasWhatsapp
                    ? AppTheme.whatsappGreen
                    : AppTheme.surface,
                border: Border.all(
                  color: hasWhatsapp
                      ? AppTheme.whatsappGreen
                      : AppTheme.iconLightGrey,
                ),
              ),
              child: hasWhatsapp
                  ? Icon(Icons.check,
                      size: 16, color: AppTheme.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
