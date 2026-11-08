import 'package:flutter/material.dart';

import '../../../configs/app_theme.dart';

/// Selectable pill used in filter sheets.
class GWidgetChoiceChip extends StatelessWidget {
  const GWidgetChoiceChip({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? color : AppTheme.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? color : AppTheme.iconLightGrey),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check_rounded,
                  size: 16, color: AppTheme.onPrimary),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: AppTheme.font(
                    color: selected ? AppTheme.onPrimary : AppTheme.textPrimary,
                    fontSize: AppTheme.textSmall,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
