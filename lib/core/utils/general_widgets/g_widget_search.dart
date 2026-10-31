import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

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
        color: AppTheme.searchFieldBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
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
          hintStyle: AppTheme.font(color: AppTheme.textLightHint, fontSize: AppTheme.textSubtitle),
          prefixIcon:
              Icon(Icons.search_rounded, color: AppTheme.iconGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: AppTheme.iconGrey, size: 20),
                  onPressed: onClear)
              : null,
        ),
      ),
    );
  }
}
