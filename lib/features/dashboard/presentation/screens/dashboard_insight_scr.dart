import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_widgets/g_widget_navi_body.dart';
import '../../../dispatch/presentation/screens/dispatch_scr.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/dashboard_metrics.dart';
import '../../domain/rules/dashboard_period.dart';
import '../controller/dashboard_bloc.dart';
import '../widgets/dashboard_widget_bar_list.dart';
import '../widgets/dashboard_widget_parts.dart';
import '../widgets/dashboard_widget_period_bar.dart';
import '../widgets/dashboard_widget_records.dart';
import '../widgets/dashboard_widget_trend_chart.dart';
import 'dashboard_technician_scr.dart';

enum DashboardInsight { visits, completion, revenue, attention }

/// Layer 2: the analysis behind one overview card. Selections on charts and
/// bars filter the record list below; leaving and coming back keeps them.
class DashboardInsightScr extends StatefulWidget {
  const DashboardInsightScr({
    super.key,
    required this.insight,
    required this.trail,
    this.fixedPeriod,
    this.initialStatus,
    this.initialBucket,
  });

  final DashboardInsight insight;
  final List<String> trail;

  /// Pins the window (e.g. today's operations) instead of the global period.
  final DashboardPeriod? fixedPeriod;
  final VisitStatus? initialStatus;
  final int? initialBucket;

  static String titleOf(DashboardInsight insight) {
    switch (insight) {
      case DashboardInsight.visits:
        return 'Visits';
      case DashboardInsight.completion:
        return 'Completion';
      case DashboardInsight.revenue:
        return 'Revenue';
      case DashboardInsight.attention:
        return 'Needs attention';
    }
  }

  /// Pushes the screen with the dashboard's bloc, so data is shared.
  static Future<void> open(
    BuildContext context, {
    required DashboardInsight insight,
    required List<String> trail,
    DashboardPeriod? fixedPeriod,
    VisitStatus? initialStatus,
    int? initialBucket,
  }) {
    final bloc = context.read<DashboardBloc>();
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: DashboardInsightScr(
            insight: insight,
            trail: [...trail, titleOf(insight)],
            fixedPeriod: fixedPeriod,
            initialStatus: initialStatus,
            initialBucket: initialBucket,
          ),
        ),
      ),
    );
  }

  @override
  State<DashboardInsightScr> createState() => _DashboardInsightScrState();
}

class _DashboardInsightScrState extends State<DashboardInsightScr> {
  late VisitStatus? _status = widget.initialStatus;
  late int? _bucket = widget.initialBucket;
  String? _category;
  DashboardPeriod? _lastPeriod;

  /// Completion list: false = not completed yet, true = completed.
  bool _showCompleted = false;

  bool get _hasFilter => _status != null || _bucket != null || _category != null;

  void _clearFilters() => setState(() {
        _status = null;
        _bucket = null;
        _category = null;
      });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardBloc>().state;
    final period = widget.fixedPeriod ?? state.period;
    // A selected bar belongs to the old period's axis, so drop it.
    if (_lastPeriod != null && _lastPeriod != period) _bucket = null;
    _lastPeriod = period;
    final now = DateTime.now();

    return GWidgetNaviBody(
      title: DashboardInsightScr.titleOf(widget.insight),
      body: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 32),
        children: [
          DashboardBreadcrumb(trail: widget.trail),
          if (widget.fixedPeriod == null &&
              widget.insight != DashboardInsight.attention) ...[
            const SizedBox(height: 10),
            DashboardWidgetPeriodBar(period: period),
          ],
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _content(state, period, now),
          ),
        ],
      ),
    );
  }

  Widget _content(DashboardState state, DashboardPeriod period, DateTime now) {
    switch (widget.insight) {
      case DashboardInsight.visits:
        return _visits(state, period);
      case DashboardInsight.completion:
        return _completion(state, period, now);
      case DashboardInsight.revenue:
        return _revenue(state, period);
      case DashboardInsight.attention:
        return _attention(state, now);
    }
  }

  // ==========================================================
  // VISITS
  // ==========================================================

  Widget _visits(DashboardState state, DashboardPeriod period) {
    final all = state.snapshot.visits ?? const [];
    final withCancelled =
        DashboardMetrics.visitsIn(all, period, includeCancelled: true);
    final active = withCancelled.where((v) => v.status != VisitStatus.cancel).toList();
    final previous = DashboardMetrics.visitsIn(all, period.previous);
    final buckets = DashboardMetrics.visitTrend(active, period);
    final statuses = DashboardMetrics.statusCounts(withCancelled);
    final categories = DashboardMetrics.categoryCounts(active);
    final statusList =
        VisitStatus.values.where((s) => statuses[s]! > 0).toList();

    final filtered = _filter(withCancelled, buckets);

    return _Stack(children: [
      DashboardGrid(columns: 3, children: [
        DashboardMiniStat(
          label: 'Visits',
          value: '${active.length}',
          delta: DashboardDelta(
              change: DashboardMetrics.change(active.length, previous.length)),
        ),
        DashboardMiniStat(
            label: 'Cancelled',
            value: '${withCancelled.length - active.length}'),
        DashboardMiniStat(
            label: 'Per day',
            value: (active.length / period.days).toStringAsFixed(1)),
      ]),
      DashboardSection(
        title: 'Visits over time',
        subtitle: 'Tap a bar to list that ${period.days > 31 ? 'week' : 'day'}',
        child: DashboardWidgetTrendChart(
          buckets: buckets,
          selectedIndex: _bucket,
          onSelect: (index) => setState(() => _bucket = index),
        ),
      ),
      DashboardSection(
        title: 'By status',
        subtitle: 'Tap a status to filter the list',
        child: statusList.isEmpty
            ? const _Note('No visits in this period')
            : DashboardWidgetBarList(
                items: [
                  for (final status in statusList)
                    DashboardBarItem(
                      label: VisitDetailHelpers.statusText(status),
                      value: statuses[status]!,
                      valueLabel: '${statuses[status]}',
                      color: VisitDetailHelpers.statusColor(status),
                      icon: VisitDetailHelpers.statusIcon(status),
                    ),
                ],
                selectedIndex:
                    _status == null ? null : statusList.indexOf(_status!),
                onTap: (i) => setState(() => _status =
                    _status == statusList[i] ? null : statusList[i]),
              ),
      ),
      if (categories.isNotEmpty)
        DashboardSection(
          title: 'By service category',
          child: DashboardWidgetBarList(
            items: [
              for (final entry in categories)
                DashboardBarItem(
                    label: entry.key,
                    value: entry.value,
                    valueLabel: '${entry.value}',
                    color: AppTheme.secondary),
            ],
            selectedIndex: _category == null
                ? null
                : categories.indexWhere((e) => e.key == _category),
            onTap: (i) => setState(() => _category =
                _category == categories[i].key ? null : categories[i].key),
          ),
        ),
      _recordsSection(filtered, buckets),
    ]);
  }

  // ==========================================================
  // COMPLETION
  // ==========================================================

  Widget _completion(
      DashboardState state, DashboardPeriod period, DateTime now) {
    final all = state.snapshot.visits ?? const [];
    final current = DashboardMetrics.visitsIn(all, period);
    final previous = DashboardMetrics.visitsIn(all, period.previous);
    final rate = DashboardMetrics.completionRate(current, now);
    final previousRate = DashboardMetrics.completionRate(previous, now);
    final dueVisits = DashboardMetrics.due(current, now);
    final completed = DashboardMetrics.completedCount(dueVisits);
    final buckets = DashboardMetrics.visitTrend(current, period);
    final technicians = DashboardMetrics.technicianStats(state.snapshot, period, now)
        .where((t) => t.visits.isNotEmpty)
        .toList();

    final source = _filter(dueVisits, buckets);
    final list = source
        .where((v) => (v.status == VisitStatus.completed) == _showCompleted)
        .toList();

    return _Stack(children: [
      DashboardGrid(columns: 3, children: [
        DashboardMiniStat(
          label: 'Completion',
          value: DashboardFormat.percent(rate),
          delta: DashboardDelta(
              change: rate == null || previousRate == null
                  ? null
                  : rate - previousRate,
              asPoints: true),
        ),
        DashboardMiniStat(label: 'Completed', value: '$completed'),
        DashboardMiniStat(
            label: 'Not done yet', value: '${dueVisits.length - completed}'),
      ]),
      const _Note('Completion = completed ÷ visits whose start time has '
          'passed. Cancelled visits are not counted.'),
      DashboardSection(
        title: 'Completed vs not completed',
        subtitle: 'Tap a bar to list that ${period.days > 31 ? 'week' : 'day'}',
        child: DashboardWidgetTrendChart(
          buckets: buckets,
          selectedIndex: _bucket,
          onSelect: (index) => setState(() => _bucket = index),
        ),
      ),
      DashboardSection(
        title: 'By technician',
        subtitle: 'Tap a technician for their full results',
        child: technicians.isEmpty
            ? const _Note('No assigned visits in this period')
            : DashboardWidgetBarList(
                maxValue: 1,
                items: [
                  for (final stat in technicians)
                    DashboardBarItem(
                      label: stat.technician.name ?? 'Technician',
                      value: stat.completionRate ?? 0,
                      valueLabel: DashboardFormat.percent(stat.completionRate),
                      note: '${stat.completed}/${stat.due}',
                      color: AppTheme.statGreen,
                    ),
                ],
                onTap: (i) => DashboardTechnicianScr.open(context,
                    technicianID: technicians[i].technician.id,
                    trail: widget.trail),
              ),
      ),
      DashboardSection(
        title: _showCompleted ? 'Completed visits' : 'Not completed yet',
        subtitle: _filterLabel(buckets),
        actionText: _hasFilter ? 'Clear filter' : null,
        onAction: _hasFilter ? _clearFilters : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: false, label: Text('Not completed')),
                ButtonSegment(value: true, label: Text('Completed')),
              ],
              selected: {_showCompleted},
              onSelectionChanged: (value) =>
                  setState(() => _showCompleted = value.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppTheme.primary.withValues(alpha: .12),
                selectedForegroundColor: AppTheme.primary,
                foregroundColor: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            DashboardWidgetVisitList(
                visits: list,
                emptyText: _showCompleted
                    ? 'No completed visits here'
                    : 'Everything due is completed'),
          ],
        ),
      ),
    ]);
  }

  // ==========================================================
  // REVENUE
  // ==========================================================

  Widget _revenue(DashboardState state, DashboardPeriod period) {
    final payments = state.snapshot.payments ?? const [];
    final invoices = state.snapshot.invoices ?? const [];
    final collected = DashboardMetrics.collected(payments, period);
    final previous = DashboardMetrics.collected(payments, period.previous);
    final buckets = DashboardMetrics.collectedTrend(payments, period);
    final periodPayments = DashboardMetrics.paymentsIn(payments, period);
    final shownPayments = _bucket == null || _bucket! >= buckets.length
        ? periodPayments
        : periodPayments
            .where((p) =>
                !p.paymentDate!.isBefore(buckets[_bucket!].from) &&
                p.paymentDate!.isBefore(buckets[_bucket!].to))
            .toList();
    final attention =
        DashboardMetrics.attention(state.snapshot, DateTime.now());

    return _Stack(children: [
      DashboardGrid(columns: 3, children: [
        DashboardMiniStat(
          label: 'Collected',
          value: DashboardFormat.money(collected),
          delta: DashboardDelta(
              change: DashboardMetrics.change(collected, previous)),
        ),
        DashboardMiniStat(
            label: 'Invoiced',
            value: DashboardFormat.money(
                DashboardMetrics.invoiced(invoices, period))),
        DashboardMiniStat(
            label: 'Outstanding',
            value: DashboardFormat.money(DashboardMetrics.outstanding(invoices))),
      ]),
      const _Note('Collected = payments minus refunds, by payment date. '
          'Outstanding is what customers owe today on issued invoices.'),
      DashboardSection(
        title: 'Money collected',
        subtitle: 'Tap a bar to list its payments',
        child: DashboardWidgetTrendChart(
          buckets: buckets,
          money: true,
          selectedIndex: _bucket,
          onSelect: (index) => setState(() => _bucket = index),
        ),
      ),
      DashboardSection(
        title: 'Payments',
        subtitle: _filterLabel(buckets),
        actionText: _bucket != null ? 'Clear filter' : null,
        onAction: _bucket != null ? _clearFilters : null,
        child: DashboardWidgetPaymentList(
            payments: shownPayments, invoices: invoices),
      ),
      DashboardSection(
        title: 'Overdue invoices',
        subtitle: 'Owed after the due date',
        child: DashboardWidgetInvoiceList(
            invoices: attention.overdueInvoices,
            emptyText: 'No overdue invoices'),
      ),
    ]);
  }

  // ==========================================================
  // ATTENTION
  // ==========================================================

  Widget _attention(DashboardState state, DateTime now) {
    final attention = DashboardMetrics.attention(state.snapshot, now);

    return _Stack(children: [
      DashboardSection(
        title: 'Late visits',
        subtitle: 'Start time passed, work not started',
        actionText: attention.late.isEmpty ? null : 'Open Dispatch',
        onAction: () => Navigator.pushNamed(context, DispatchScr.route),
        child: DashboardWidgetVisitList(
            visits: attention.late, emptyText: 'Nothing is late'),
      ),
      DashboardSection(
        title: 'Waiting for a technician',
        subtitle: 'Scheduled visits without anyone assigned',
        actionText: attention.needsTechnician.isEmpty ? null : 'Assign in Dispatch',
        onAction: () => Navigator.pushNamed(context, DispatchScr.route),
        child: DashboardWidgetVisitList(
            visits: attention.needsTechnician,
            emptyText: 'Every scheduled visit has a technician'),
      ),
      DashboardSection(
        title: 'Ready to invoice',
        subtitle: 'Completed visits with an unissued invoice',
        child: DashboardWidgetVisitList(
            visits: attention.readyToInvoice,
            emptyText: 'All completed work is invoiced'),
      ),
      DashboardSection(
        title: 'Overdue invoices',
        subtitle: 'Money still owed after the due date',
        child: DashboardWidgetInvoiceList(
            invoices: attention.overdueInvoices,
            emptyText: 'No overdue invoices'),
      ),
    ]);
  }

  // ==========================================================
  // SHARED
  // ==========================================================

  List<VisitDetailModel> _filter(
      List<VisitDetailModel> visits, List<DashboardBucket> buckets) {
    final bucket =
        _bucket == null || _bucket! >= buckets.length ? null : buckets[_bucket!];
    return visits.where((v) {
      if (_status != null && (v.status ?? VisitStatus.draft) != _status) {
        return false;
      }
      if (_category != null &&
          (v.category?.name ?? 'Uncategorized') != _category) {
        return false;
      }
      if (bucket != null &&
          (v.startDate!.isBefore(bucket.from) ||
              !v.startDate!.isBefore(bucket.to))) {
        return false;
      }
      return true;
    }).toList();
  }

  String _filterLabel(List<DashboardBucket> buckets) {
    final parts = [
      if (_status != null) VisitDetailHelpers.statusText(_status),
      if (_category != null) _category!,
      if (_bucket != null && _bucket! < buckets.length)
        VisitDetailHelpers.date(buckets[_bucket!].from),
    ];
    return parts.isEmpty ? 'All in this period' : 'Filtered: ${parts.join(' · ')}';
  }

  Widget _recordsSection(
      List<VisitDetailModel> visits, List<DashboardBucket> buckets) {
    return DashboardSection(
      title: '${visits.length} visit${visits.length == 1 ? '' : 's'}',
      subtitle: _filterLabel(buckets),
      actionText: _hasFilter ? 'Clear filter' : null,
      onAction: _hasFilter ? _clearFilters : null,
      child: DashboardWidgetVisitList(
          visits: visits, emptyText: 'No visits match this selection'),
    );
  }
}

class _Stack extends StatelessWidget {
  const _Stack({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          children[i],
        ],
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded,
            size: 15, color: AppTheme.textLightHint),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: AppTheme.font(
                  color: AppTheme.textSecondary, fontSize: AppTheme.textCaption, height: 1.4)),
        ),
      ],
    );
  }
}
