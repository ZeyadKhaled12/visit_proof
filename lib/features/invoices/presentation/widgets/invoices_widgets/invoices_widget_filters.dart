import 'package:flutter/material.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../core/utils/general_widgets/g_widget_search.dart';

class InvoicesWidgetFilters extends StatelessWidget {
  const InvoicesWidgetFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: GWidgetSearch(
                hint: 'Search for invoice number, visit number, etc...',
                searchController: TextEditingController(),
                onChanged: (value) {},
                onClear: () {})),
        const SizedBox(width: 12),

        // Advanced Filter Button
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.fabShadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune_rounded, // or Icons.filter_list
              color: AppColors.surfaceWhite,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
