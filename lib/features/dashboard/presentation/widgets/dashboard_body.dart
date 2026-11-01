import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../core/utils/general_widgets/g_widget_empty.dart';
import '../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../../core/utils/general_widgets/g_widget_menu_button.dart';
import '../../../add_visit/presentation/screens/add_visit_scr.dart';
import '../../domain/rules/dashboard_metrics.dart';
import '../../domain/rules/dashboard_period.dart';
import '../controller/dashboard_bloc.dart';
import '../screens/dashboard_insight_scr.dart';
import '../screens/dashboard_technician_scr.dart';
import 'dashboard_widget_attention.dart';
import 'dashboard_widget_kpi_card.dart';
import 'dashboard_widget_parts.dart';
import 'dashboard_widget_period_bar.dart';
import 'dashboard_widget_quick_links.dart';
import 'dashboard_widget_technicians.dart';
import 'dashboard_widget_today.dart';
import 'dashboard_widget_trend_chart.dart';

/// Layer 1: what is happening, what needs attention, where to go next.
class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key, required this.state});
  final DashboardState state;

  static List<String> _trail = ['Overview'.tr];
  static const double _wideBreakpoint = 900;

  void _reload(BuildContext context) => context
      .read<DashboardBloc>()
      .add(const GetDashboardEvent(noParameters: NoParameters()));

  void _openInsight(BuildContext context, DashboardInsight insight,
          {int? bucket, VisitStatus? status, DashboardPeriod? fixedPeriod}) =>
      DashboardInsightScr.open(context,
          insight: insight,
          trail: _trail,
          initialBucket: bucket,
          initialStatus: status,
          fixedPeriod: fixedPeriod);

  @override
  Widget build(BuildContext context) {
    final loading = state.getDashboardRequestState == RequestState.loading;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        top: true,
        child: !state.hasData
            ? _firstLoad(context, loading)
            : GWidgetLoading(
                isLoading: loading,
                opacity: .7,
                body: RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () async => _reload(context),
                  child: _content(context),
                ),
              ),
      ),
    );
  }

  Widget _firstLoad(BuildContext context, bool loading) {
    if (loading || state.getDashboardRequestState == RequestState.loaded) {
      return Center(
          child: GWidgetLoadingCircle(color: AppTheme.primary, strokeWidth: 4));
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GWidgetEmpty(
            icon: Icons.cloud_off_rounded,
            title: 'The dashboard could not load'.tr,
            subtitle: 'Your data is safe. Try again in a moment.'.tr,
          ),
          GWidgetButton(
              text: 'Try again'.tr,
              fontSize: AppTheme.textSubtitle,
              width: 160,
              raduis: 12,
              onPressed: () => _reload(context)),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    final snapshot = state.snapshot;
    final visits = snapshot.visits ?? const [];

    if (visits.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _Header(state: state, onRefresh: () => _reload(context)),
          GWidgetEmpty(
            icon: Icons.insights_rounded,
            title: 'Your dashboard starts with a visit'.tr,
            subtitle: 'Create visits and assign technicians to see your operations, completion and revenue here.'.tr,
            actionText: 'Create first visit'.tr,
            onAction: () async {
              await Navigator.pushNamed(context, AddVisitScr.route);
              if (context.mounted) _reload(context);
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: DashboardWidgetQuickLinks(),
          ),
        ],
      );
    }

    final now = DateTime.now();
    final period = state.period;
    final current = DashboardMetrics.visitsIn(visits, period);
    final previous = DashboardMetrics.visitsIn(visits, period.previous);
    final dueNow = DashboardMetrics.due(current, now);
    final rate = DashboardMetrics.completionRate(current, now);
    final previousRate = DashboardMetrics.completionRate(previous, now);
    final payments = snapshot.payments ?? const [];
    final collected = DashboardMetrics.collected(payments, period);
    final previousCollected = DashboardMetrics.collected(payments, period.previous);
    final outstanding = DashboardMetrics.outstanding(snapshot.invoices ?? const []);
    final attention = DashboardMetrics.attention(snapshot, now);
    final technicians = DashboardMetrics.technicianStats(snapshot, period, now);
    final buckets = DashboardMetrics.visitTrend(current, period);

    final kpis = [
      DashboardWidgetKpiCard(
        label: 'Visits'.tr,
        value: '${current.length}',
        icon: Icons.event_note_rounded,
        color: AppTheme.primary,
        caption: '{0} due so far'.trArgs([dueNow.length]),
        footer: DashboardDelta(
            change: DashboardMetrics.change(current.length, previous.length)),
        onTap: () => _openInsight(context, DashboardInsight.visits),
      ),
      DashboardWidgetKpiCard(
        label: 'Completion'.tr,
        value: DashboardFormat.percent(rate),
        icon: Icons.task_alt_rounded,
        color: AppTheme.statGreen,
        caption: rate == null
            ? 'Nothing due yet'.tr
            : '{0} of {1} done'.trArgs([DashboardMetrics.completedCount(dueNow), dueNow.length]),
        footer: DashboardDelta(
            change: rate == null || previousRate == null
                ? null
                : rate - previousRate,
            asPoints: true),
        onTap: () => _openInsight(context, DashboardInsight.completion),
      ),
      DashboardWidgetKpiCard(
        label: 'Collected'.tr,
        value: DashboardFormat.money(collected),
        icon: Icons.payments_rounded,
        color: AppTheme.secondary,
        caption: '{0} outstanding'.trArgs([DashboardFormat.money(outstanding)]),
        footer: DashboardDelta(
            change: DashboardMetrics.change(collected, previousCollected)),
        onTap: () => _openInsight(context, DashboardInsight.revenue),
      ),
      DashboardWidgetKpiCard(
        label: 'Needs attention'.tr,
        value: '${attention.total}',
        icon: Icons.notification_important_rounded,
        color: attention.total > 0 ? AppTheme.statOrange : AppTheme.statGreen,
        caption: attention.total > 0 ? 'Items to handle now'.tr : 'All on track'.tr,
        alert: attention.total > 0,
        onTap: () => _openInsight(context, DashboardInsight.attention),
      ),
    ];

    final attentionPanel = DashboardWidgetAttention(
        attention: attention,
        onOpen: () => _openInsight(context, DashboardInsight.attention));
    final todayPanel = DashboardWidgetToday(
      visits: visits,
      onStage: (status) => _openInsight(context, DashboardInsight.visits,
          status: status,
          fixedPeriod: DashboardPeriod.of(DashboardRange.today, now: now)),
    );
    final trendPanel = DashboardSection(
      title: 'Visits trend'.tr,
      subtitle: '{0} · tap a bar to see those visits'.trArgs([period.label]),
      actionText: 'Details'.tr,
      onAction: () => _openInsight(context, DashboardInsight.visits),
      child: DashboardWidgetTrendChart(
        buckets: buckets,
        onSelect: (index) {
          if (index != null) {
            _openInsight(context, DashboardInsight.visits, bucket: index);
          }
        },
      ),
    );
    final technicianPanel = DashboardWidgetTechnicians(
      stats: technicians,
      onTechnician: (id) =>
          DashboardTechnicianScr.open(context, technicianID: id, trail: _trail),
      onSeeAll: () => _openInsight(context, DashboardInsight.completion),
    );

    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= _wideBreakpoint;
      const gap = SizedBox(height: 14);

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _Header(state: state, onRefresh: () => _reload(context)),
          DashboardWidgetPeriodBar(period: period),
          gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DashboardGrid(columns: wide ? 4 : 2, children: kpis),
                gap,
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [trendPanel, gap, technicianPanel],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            attentionPanel,
                            gap,
                            todayPanel,
                            gap,
                            const DashboardWidgetQuickLinks(),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  attentionPanel,
                  gap,
                  todayPanel,
                  gap,
                  trendPanel,
                  gap,
                  technicianPanel,
                  gap,
                  const DashboardWidgetQuickLinks(),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.onRefresh});
  final DashboardState state;
  final VoidCallback onRefresh;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning'.tr;
    if (hour < 17) return 'Good afternoon'.tr;
    return 'Good evening'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final loadedAt = state.snapshot.loadedAt;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 12, 14),
      child: Row(
        children: [
          const GWidgetMenuButton(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting,
                    style: AppTheme.font(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.textBody,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Operations overview'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textHeadline,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.3)),
                const SizedBox(height: 2),
                Text(
                    '${state.period.dateLabel} · ${state.period.comparisonLabel}'
                    '${loadedAt == null ? '' : ' · updated ${DateFormat('hh:mm a').format(loadedAt)}'}',
                    maxLines: 2,
                    style: AppTheme.font(
                        color: AppTheme.textLightHint, fontSize: AppTheme.textCaption)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh'.tr,
            onPressed: onRefresh,
            icon: Icon(Icons.refresh_rounded, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}
