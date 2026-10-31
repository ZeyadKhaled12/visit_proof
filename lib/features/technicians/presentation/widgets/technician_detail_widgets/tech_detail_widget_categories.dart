import 'package:flutter/material.dart';

import '../../../../../configs/app_theme.dart';
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
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                category,
                style: AppTheme.font(
                  color: AppTheme.primary,
                  fontSize: AppTheme.textBody,
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
