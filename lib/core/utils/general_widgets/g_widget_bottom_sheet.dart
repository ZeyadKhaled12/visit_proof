import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_fonts.dart';

import '../../../configs/app_colors.dart';

class GWidgetBottomSheet extends StatelessWidget {
  const GWidgetBottomSheet(
      {super.key, required this.title, this.subtitle, required this.body});
  final String title;
  final String? subtitle;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(bottom: bottomInset),
        padding: EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.iconLightGrey,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppFonts(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.iconGrey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppFonts(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textNotes,
                  ),
                ),
              SizedBox(height: 15),
              body
            ],
          ),
        ),
      ),
    );
  }
}
