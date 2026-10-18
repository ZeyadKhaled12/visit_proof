import 'package:flutter/material.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';

// Mock list of available categories
final List<String> _availableCategories = [
  'Plumbing',
  'Electrical',
  'HVAC',
  'Networking',
  'Carpentry',
  'Smart Home',
  'Painting',
];

class AddTechWidgetCategories extends StatelessWidget {
  const AddTechWidgetCategories(
      {super.key,
      required this.selectedCategories,
      required this.onRemove,
      required this.onAdd,
      this.isError = false});
  final Set<String> selectedCategories;
  final void Function(String category) onRemove;
  final void Function(String category) onAdd;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(
            'Categories',
            style: AppFonts(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: isError ? Border.all(color: AppColors.statOrange) : null,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 12,
            children: _availableCategories.map((category) {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : AppColors.locationChipBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.secondary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category,
                        style: AppFonts(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                      ]
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}
