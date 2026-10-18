import 'package:flutter/material.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
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
              ? AppColors.whatsappGreen.withValues(alpha: 0.1)
              : AppColors.locationChipBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasWhatsapp
                ? AppColors.whatsappGreen
                : AppColors.iconLightGrey.withValues(alpha: 0.5),
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
                        color: AppColors.whatsappGreen,
                        width: 26,
                        height: 26)
                    : Image(
                        image: AssetImage(IconAsset.whatsapp),
                        color: AppColors.iconGrey,
                        width: 26,
                        height: 26)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Number includes WhatsApp',
                style: AppFonts(
                  color: hasWhatsapp
                      ? AppColors.whatsappGreen
                      : AppColors.textDarkHint,
                  fontWeight: hasWhatsapp ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
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
                    ? AppColors.whatsappGreen
                    : AppColors.surfaceWhite,
                border: Border.all(
                  color: hasWhatsapp
                      ? AppColors.whatsappGreen
                      : AppColors.iconLightGrey,
                ),
              ),
              child: hasWhatsapp
                  ? const Icon(Icons.check,
                      size: 16, color: AppColors.surfaceWhite)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
