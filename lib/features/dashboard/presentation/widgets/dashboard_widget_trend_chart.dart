import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../configs/app_theme.dart';
import '../../domain/rules/dashboard_metrics.dart';
import 'dashboard_widget_parts.dart';

/// Bars over time. Visits mode stacks completed (green) under not yet
/// completed (purple); money mode shows one series. Tap a bar to select it:
/// the readout above shows its exact values and the caller can filter by it.
class DashboardWidgetTrendChart extends StatefulWidget {
  const DashboardWidgetTrendChart({
    super.key,
    required this.buckets,
    this.money = false,
    this.selectedIndex,
    this.onSelect,
    this.height = 160,
  });

  final List<DashboardBucket> buckets;
  final bool money;

  /// Controlled selection; when null the chart keeps its own.
  final int? selectedIndex;
  final ValueChanged<int?>? onSelect;
  final double height;

  static Color get completedColor => AppTheme.statGreen;
  static Color get openColor => AppTheme.primary;

  @override
  State<DashboardWidgetTrendChart> createState() =>
      _DashboardWidgetTrendChartState();
}

class _DashboardWidgetTrendChartState extends State<DashboardWidgetTrendChart> {
  int? _localSelection;

  int? get _selected =>
      widget.onSelect != null ? widget.selectedIndex : _localSelection;

  num _value(DashboardBucket b) => widget.money ? b.amount : b.total;

  void _tap(Offset position, double width) {
    final count = widget.buckets.length;
    if (count == 0) return;
    final index = (position.dx / (width / count)).floor().clamp(0, count - 1);
    final next = _selected == index ? null : index;
    if (widget.onSelect != null) {
      widget.onSelect!(next);
    } else {
      setState(() => _localSelection = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buckets = widget.buckets;
    final hasData = buckets.any((b) => _value(b) > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Readout(
            buckets: buckets,
            selected: _selected,
            money: widget.money),
        const SizedBox(height: 10),
        SizedBox(
          height: widget.height,
          child: hasData
              ? LayoutBuilder(builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) =>
                        _tap(details.localPosition, constraints.maxWidth),
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, widget.height),
                      painter: _BarsPainter(
                        buckets: buckets,
                        money: widget.money,
                        selected: _selected,
                      ),
                    ),
                  );
                })
              : Center(
                  child: Text(
                      widget.money
                          ? 'No payments in this period'.tr
                          : 'No visits in this period'.tr,
                      style: AppTheme.font(
                          color: AppTheme.textSecondary, fontSize: AppTheme.textBody)),
                ),
        ),
        if (!widget.money && hasData) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              _Legend(color: DashboardWidgetTrendChart.completedColor, label: 'Completed'.tr),
              SizedBox(width: 16),
              _Legend(color: DashboardWidgetTrendChart.openColor, label: 'Not completed'.tr),
            ],
          ),
        ],
      ],
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout(
      {required this.buckets, required this.selected, required this.money});
  final List<DashboardBucket> buckets;
  final int? selected;
  final bool money;

  @override
  Widget build(BuildContext context) {
    final index = selected;
    final bucket = index == null || index >= buckets.length ? null : buckets[index];
    final days = bucket == null ? 0 : bucket.to.difference(bucket.from).inDays;
    final title = bucket == null
        ? 'Tap a bar for details'.tr
        : days > 1
            ? 'Week of {0}'.trArgs([DateFormat('dd MMM').format(bucket.from)])
            : DateFormat('EEE, dd MMM').format(bucket.from);

    final value = bucket == null
        ? (money
            ? DashboardFormat.money(buckets.fold<num>(0, (s, b) => s + b.amount))
            : '{0} visits'.trArgs([buckets.fold<int>(0, (s, b) => s + b.total)]))
        : money
            ? DashboardFormat.money(bucket.amount)
            : '{0} visit{1} · {2} completed'.trArgs([bucket.total, bucket.total == 1 ? '' : 's', bucket.completed]);

    return Row(
      children: [
        Expanded(
          child: Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.font(
                  color: bucket == null
                      ? AppTheme.textLightHint
                      : AppTheme.textSecondary,
                  fontSize: AppTheme.textSmall,
                  fontWeight: FontWeight.w600)),
        ),
        Flexible(
          child: Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: AppTheme.font(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.textBody,
                  fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: AppTheme.font(color: AppTheme.textSecondary, fontSize: AppTheme.textCaption)),
      ],
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.buckets,
    required this.money,
    required this.selected,
  });

  final List<DashboardBucket> buckets;
  final bool money;
  final int? selected;

  static const double _labelHeight = 18;
  static const double _gap = 2;
  static const double _maxBarWidth = 18;
  static const double _minLabelSpacing = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height - _labelHeight;
    final maxValue = buckets.fold<num>(
        0, (m, b) => (money ? b.amount : b.total) > m ? (money ? b.amount : b.total) : m);
    if (maxValue <= 0) return;

    // Recessive gridlines at 0, half and max, labeled on the left edge.
    final grid = Paint()
      ..color = AppTheme.iconLightGrey.withValues(alpha: .35)
      ..strokeWidth = 1;
    for (final fraction in [0.0, .5, 1.0]) {
      final y = chartHeight - chartHeight * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
      if (fraction > 0) {
        final value = maxValue * fraction;
        _text(
            canvas,
            money ? DashboardFormat.money(value) : value.round().toString(),
            Offset(0, y + 2),
            AppTheme.textLightHint,
            9.5);
      }
    }

    final slot = size.width / buckets.length;
    final barWidth = (slot * .6).clamp(3, _maxBarWidth).toDouble();
    final labelEvery =
        (buckets.length / (size.width / _minLabelSpacing)).ceil().clamp(1, 999);

    for (var i = 0; i < buckets.length; i++) {
      final bucket = buckets[i];
      final x = slot * i + (slot - barWidth) / 2;
      final faded = selected != null && selected != i;
      final scale = chartHeight / maxValue;

      if (money) {
        final h = (bucket.amount.clamp(0, maxValue) * scale).toDouble();
        _bar(canvas, x, chartHeight - h, barWidth, h,
            DashboardWidgetTrendChart.openColor, faded);
      } else {
        final completedHeight = bucket.completed * scale;
        final openHeight = bucket.open * scale;
        _bar(canvas, x, chartHeight - completedHeight, barWidth,
            completedHeight, DashboardWidgetTrendChart.completedColor, faded);
        final openBottom =
            chartHeight - completedHeight - (completedHeight > 0 ? _gap : 0);
        _bar(canvas, x, openBottom - openHeight, barWidth, openHeight,
            DashboardWidgetTrendChart.openColor, faded);
      }

      if (i % labelEvery == 0 || i == selected) {
        _text(canvas, bucket.label, Offset(slot * i + slot / 2, chartHeight + 4),
            i == selected ? AppTheme.textPrimary : AppTheme.textSecondary,
            10,
            center: true);
      }
    }
  }

  void _bar(Canvas canvas, double x, double y, double width, double height,
      Color color, bool faded) {
    if (height <= 0) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, width, height),
          Radius.circular(height < 8 ? height / 2 : 4)),
      Paint()..color = faded ? color.withValues(alpha: .3) : color,
    );
  }

  void _text(Canvas canvas, String text, Offset at, Color color, double size,
      {bool center = false}) {
    final painter = TextPainter(
      text: TextSpan(
          text: text,
          style: AppTheme.font(color: color, fontSize: size, fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
        canvas, center ? at.translate(-painter.width / 2, 0) : at);
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.buckets != buckets || old.money != money || old.selected != selected;
}
