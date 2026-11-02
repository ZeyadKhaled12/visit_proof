import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../configs/app_theme.dart';

/// Formatting shared by dashboard widgets.
class DashboardFormat {
  DashboardFormat._();

  static String percent(double? value) =>
      value == null ? '—' : '${(value * 100).round()}%';

  /// 950 SAR · 12.4K SAR · 1.2M SAR
  static String money(num value) {
    final abs = value.abs();
    final sign = value < 0 ? '-' : '';
    if (abs >= 1000000) {
      return '$sign${(abs / 1000000).toStringAsFixed(1)}M ${App.currency}';
    }
    if (abs >= 10000) {
      return '$sign${(abs / 1000).toStringAsFixed(1)}K ${App.currency}';
    }
    return '$sign${abs.toStringAsFixed(abs % 1 == 0 ? 0 : 2)} ${App.currency}';
  }
}

/// White card with a title, an optional note and an optional "details" link.
class DashboardSection extends StatelessWidget {
  const DashboardSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.iconLightGrey.withValues(alpha: .25)),
        boxShadow: [
          BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTheme.font(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.textSubtitle,
                            fontWeight: FontWeight.w800)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: AppTheme.font(
                              color: AppTheme.textSecondary, fontSize: AppTheme.textSmall)),
                    ],
                  ],
                ),
              ),
              if (actionText != null && onAction != null)
                InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(actionText!,
                            style: AppTheme.font(
                                color: AppTheme.primary,
                                fontSize: AppTheme.textSmall,
                                fontWeight: FontWeight.w700)),
                        Icon(Icons.chevron_right_rounded,
                            size: 18, color: AppTheme.primary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Change vs the previous period. Color shows whether the change is good,
/// not whether the number went up.
class DashboardDelta extends StatelessWidget {
  const DashboardDelta({
    super.key,
    required this.change,
    this.higherIsBetter = true,
    this.asPoints = false,
  });

  /// Relative change (0.12 = +12 %), or percentage points when [asPoints].
  final double? change;
  final bool higherIsBetter;
  final bool asPoints;

  @override
  Widget build(BuildContext context) {
    final value = change;
    if (value == null) {
      return Text('No earlier data'.tr,
          style: AppTheme.font(color: AppTheme.textLightHint, fontSize: AppTheme.textCaption));
    }

    final flat = (value * 100).round() == 0;
    final good = flat ? null : (value > 0) == higherIsBetter;
    final color = good == null
        ? AppTheme.iconGrey
        : good
            ? AppTheme.statGreen
            : AppTheme.statOrange;
    final amount = (value.abs() * 100).round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
            flat
                ? Icons.remove_rounded
                : value > 0
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
            size: 13,
            color: color),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
              flat
                  ? 'No change'.tr
                  : asPoints
                      ? '{0} pts'.trArgs([amount])
                      : '$amount%',
              overflow: TextOverflow.ellipsis,
              style: AppTheme.font(
                  color: color, fontSize: AppTheme.textCaption, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

/// Where the admin is in the drill-down. Tapping a crumb goes back to it.
class DashboardBreadcrumb extends StatelessWidget {
  const DashboardBreadcrumb({super.key, required this.trail});
  final List<String> trail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < trail.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.chevron_right_rounded,
                    size: 16, color: AppTheme.iconLightGrey),
              ),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: i == trail.length - 1
                  ? null
                  : () {
                      // Each crumb is one screen; pop back to the tapped one.
                      var pops = trail.length - 1 - i;
                      Navigator.popUntil(context, (_) => pops-- <= 0);
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Text(trail[i],
                    style: AppTheme.font(
                        color: i == trail.length - 1
                            ? AppTheme.textPrimary
                            : AppTheme.primary,
                        fontSize: AppTheme.textSmall,
                        fontWeight: i == trail.length - 1
                            ? FontWeight.w800
                            : FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small labeled value used in KPI rows of detail screens.
class DashboardMiniStat extends StatelessWidget {
  const DashboardMiniStat({
    super.key,
    required this.label,
    required this.value,
    this.delta,
  });

  final String label;
  final String value;
  final Widget? delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.locationChipBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.font(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.textCaption,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(value,
                style: AppTheme.font(
                    color: AppTheme.textPrimary,
                    fontSize: AppTheme.textTitleLarge,
                    fontWeight: FontWeight.w800)),
          ),
          if (delta != null) ...[const SizedBox(height: 2), delta!],
        ],
      ),
    );
  }
}

/// Lays out children in [columns] equal columns that wrap, keeping each
/// child's natural height (no fixed aspect ratio that could overflow).
class DashboardGrid extends StatelessWidget {
  const DashboardGrid({
    super.key,
    required this.children,
    this.columns = 2,
    this.spacing = 10,
  });

  final List<Widget> children;
  final int columns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width =
          (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    });
  }
}
