import 'package:flutter/material.dart';

import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';

class GWidgetSearch extends StatelessWidget {
  const GWidgetSearch(
      {super.key,
      required this.hint,
      required this.searchController,
      required this.onChanged,
      required this.onClear});
  final String hint;
  final TextEditingController searchController;
  final Function(String? value) onChanged;
  final Function() onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.searchFieldBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppFonts(color: AppColors.textLightHint, fontSize: 15),
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.iconGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.iconGrey, size: 20),
                  onPressed: onClear)
              : null,
        ),
      ),
    );
  }
}
