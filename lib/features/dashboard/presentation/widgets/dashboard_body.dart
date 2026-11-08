import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../app/app.dart';
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
import 'dashboard_widget_tour.dart';
import 'dashboard_widget_trend_chart.dart';

/// Layer 1: what is happening, what needs attention, where to go next.
class DashboardBody extends StatefulWidget {
  const DashboardBody({super.key, required this.state});
  final DashboardState state;

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  final _tour = DashboardTourKeys();

  DashboardState get state => widget.state;

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
          KeyedSubtree(
            key: _tour.header,
            child: _Header(
                state: state,
                onRefresh: () => _reload(context),
                onHelp: () => DashboardTour.start(context, _tour)),
          ),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: KeyedSubtree(
                key: _tour.links, child: const DashboardWidgetQuickLinks()),
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
        caption: '{0} due so far'.trArgs([dueNow.length]),
        footer: DashboardDelta(
            change: DashboardMetrics.change(current.length, previous.length)),
        onTap: () => _openInsight(context, DashboardInsight.visits),
      ),
      DashboardWidgetKpiCard(
        label: 'Completion'.tr,
        value: rate == null ? '—' : '${(rate * 100).round()}',
        unit: rate == null ? null : '%',
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
        value: DashboardFormat.amount(collected),
        unit: ' ${App.currency}',
        caption: '{0} outstanding'.trArgs([DashboardFormat.money(outstanding)]),
        footer: DashboardDelta(
            change: DashboardMetrics.change(collected, previousCollected)),
        onTap: () => _openInsight(context, DashboardInsight.revenue),
      ),
      DashboardWidgetKpiCard(
        label: 'Needs attention'.tr,
        value: '${attention.total}',
        caption: attention.total > 0 ? 'Items to handle now'.tr : 'All on track'.tr,
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

    Widget mark(GlobalKey key, Widget child) =>
        KeyedSubtree(key: key, child: child);

    final newVisit = mark(_tour.newVisit, const DashboardWidgetNewVisit());
    final attentionCard = mark(_tour.attention, attentionPanel);
    final todayCard = mark(_tour.today, todayPanel);
    final trendCard = mark(_tour.trend, trendPanel);
    final technicianCard = mark(_tour.technicians, technicianPanel);
    final links = mark(_tour.links, const DashboardWidgetQuickLinks());

    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= _wideBreakpoint;
      const gap = SizedBox(height: 12);
      final scores = mark(
          _tour.scores, DashboardGrid(columns: wide ? 4 : 2, children: kpis));

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          KeyedSubtree(
            key: _tour.header,
            child: _Header(
                state: state,
                onRefresh: () => _reload(context),
                onHelp: () => DashboardTour.start(context, _tour)),
          ),
          gap,
          mark(_tour.period, DashboardWidgetPeriodBar(period: period)),
          gap,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                newVisit,
                gap,
                if (wide) ...[
                  scores,
                  gap,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [trendCard, gap, technicianCard],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [attentionCard, gap, todayCard, gap, links],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  attentionCard,
                  gap,
                  scores,
                  gap,
                  todayCard,
                  gap,
                  trendCard,
                  gap,
                  technicianCard,
                  gap,
                  links,
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
  const _Header(
      {required this.state, required this.onRefresh, required this.onHelp});
  final DashboardState state;
  final VoidCallback onRefresh;
  final VoidCallback onHelp;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning'.tr;
    if (hour < 17) return 'Good afternoon'.tr;
    return 'Good evening'.tr;
  }

  Widget _action(IconData icon, String tooltip, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 6),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: AppTheme.locationChipBg,
          fixedSize: const Size(44, 44),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Icon(icon, color: AppTheme.textPrimary, size: 22),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadedAt = state.snapshot.loadedAt;

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 16, 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.iconLightGrey)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GWidgetMenuButton(),
              Expanded(
                child: Text(_greeting,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.textBody,
                        fontWeight: FontWeight.w600)),
              ),
              _action(Icons.help_outline_rounded, 'How this screen works'.tr,
                  onHelp),
              _action(Icons.refresh_rounded, 'Refresh'.tr, onRefresh),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Operations overview'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        color: AppTheme.textPrimary,
                        fontSize: AppTheme.textHeadline,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                    '${state.period.dateLabel} · ${state.period.comparisonLabel}'
                    '${loadedAt == null ? '' : ' · ${'updated {0}'.trArgs([DateFormat('hh:mm a').format(loadedAt)])}'}',
                    maxLines: 2,
                    style: AppTheme.font(
                        color: AppTheme.textDarkHint,
                        fontSize: AppTheme.textCaption)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
