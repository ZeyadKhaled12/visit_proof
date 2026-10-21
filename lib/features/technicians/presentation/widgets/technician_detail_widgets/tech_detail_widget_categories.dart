import 'package:flutter/material.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';
import '../../../../clients/presentation/widgets/client_detail_widgets/client_detail_widget_title_card.dart';

class TechDetailWidgetCategories extends StatelessWidget {
  const TechDetailWidgetCategories({super.key, required this.categories});
  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientDetailWidgetTitle(
          title: 'Categories',
          icon: Icons.category,
          addLoading: false,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0, // horizontal gap between chips
          runSpacing: 8.0, // vertical gap between lines of chips
          crossAxisAlignment: WrapCrossAlignment.start,
          children: categories.map((category) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                category,
                style: AppFonts(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
