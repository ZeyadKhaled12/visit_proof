import 'package:flutter/material.dart';

import '../../../../configs/app_theme.dart';

class DashboardBarItem {
  final String label;
  final num value;
  final String valueLabel;
  final Color color;
  final IconData? icon;

  /// Optional note after the value, e.g. a completion rate.
  final String? note;

  const DashboardBarItem({
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.color,
    this.icon,
    this.note,
  });
}

/// Labeled horizontal bars for comparing categories. Every row is named and
/// numbered, so identity never depends on color alone. Tapping a row selects
/// it (the caller filters by it).
class DashboardWidgetBarList extends StatelessWidget {
  const DashboardWidgetBarList({
    super.key,
    required this.items,
    this.selectedIndex,
    this.onTap,
    this.maxValue,
  });

  final List<DashboardBarItem> items;
  final int? selectedIndex;
  final ValueChanged<int>? onTap;

  /// Scale maximum; defaults to the largest value.
  final num? maxValue;

  @override
  Widget build(BuildContext context) {
    final max = maxValue ??
        items.fold<num>(0, (m, item) => item.value > m ? item.value : m);

    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          _Row(
            item: items[i],
            fraction: max <= 0 ? 0 : (items[i].value / max).clamp(0, 1).toDouble(),
            selected: selectedIndex == i,
            dimmed: selectedIndex != null && selectedIndex != i,
            onTap: onTap == null ? null : () => onTap!(i),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.item,
    required this.fraction,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final DashboardBarItem item;
  final double fraction;
  final bool selected;
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? .45 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
          decoration: BoxDecoration(
            color: selected
                ? item.color.withValues(alpha: .08)
                : AppTheme.onPrimary.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(item.icon, size: 15, color: item.color),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.font(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.textBody,
                            fontWeight: FontWeight.w600)),
                  ),
                  if (item.note != null) ...[
                    Text(item.note!,
                        style: AppTheme.font(
                            color: AppTheme.textSecondary, fontSize: AppTheme.textCaption)),
                    const SizedBox(width: 8),
                  ],
                  Text(item.valueLabel,
                      style: AppTheme.font(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.textBody,
                          fontWeight: FontWeight.w800)),
                  if (onTap != null)
                    Icon(
                        selected
                            ? Icons.filter_alt_rounded
                            : Icons.chevron_right_rounded,
                        size: 16,
                        color: selected ? item.color : AppTheme.iconLightGrey),
                ],
              ),
              const SizedBox(height: 6),
              LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.locationChipBg,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 6,
                      width: constraints.maxWidth * fraction,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
