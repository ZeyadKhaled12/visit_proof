import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_loading.dart';

import '../../../../../configs/app_theme.dart';

// Mock list of available categories

class AddTechWidgetCategories extends StatelessWidget {
  const AddTechWidgetCategories(
      {super.key,
      required this.selectedCategories,
      required this.onRemove,
      required this.onAdd,
      this.isError = false,
      required this.categoriesLoading,
      required this.categories});
  final Set<GModelCatg> selectedCategories;
  final void Function(GModelCatg category) onRemove;
  final void Function(GModelCatg category) onAdd;
  final bool categoriesLoading;
  final List<GModelCatg> categories;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(
            'Categories'.tr,
            style: AppTheme.font(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.textBodyLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GWidgetLoading(
          isLoading: categoriesLoading,
          body: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: isError ? Border.all(color: AppTheme.statOrange) : null,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 12,
              //_availableCategories
              children: categories.map((category) {
                final isSelected = selectedCategories.contains(category);
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      onRemove(category);
                    } else {
                      onAdd(category);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.secondary.withValues(alpha: 0.15)
                          : AppTheme.locationChipBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.secondary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category.name ?? '',
                          style: AppTheme.font(
                            color: isSelected
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontSize: AppTheme.textBody,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: AppTheme.secondary,
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        )
      ],
    );
  }
}
