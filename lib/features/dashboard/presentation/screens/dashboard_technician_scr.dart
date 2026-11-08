import 'package:visit_proof/configs/app_tours.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/enums/technician_status_enum.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_widgets/g_widget_navi_body.dart';
import '../../../technicians/presentation/screens/technician_detail_scr.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
import '../../domain/rules/dashboard_metrics.dart';
import '../../domain/rules/dashboard_period.dart';
import '../controller/dashboard_bloc.dart';
import '../widgets/dashboard_widget_bar_list.dart';
import '../widgets/dashboard_widget_parts.dart';
import '../widgets/dashboard_widget_period_bar.dart';
import '../widgets/dashboard_widget_records.dart';
import '../widgets/dashboard_widget_trend_chart.dart';

/// Layer 3: one technician's results in the selected period.
class DashboardTechnicianScr extends StatefulWidget {
  const DashboardTechnicianScr(
      {super.key, required this.technicianID, required this.trail});
  final String? technicianID;
  final List<String> trail;

  static Future<void> open(BuildContext context,
      {required String? technicianID, required List<String> trail}) {
    final bloc = context.read<DashboardBloc>();
    final name = bloc.state.snapshot.technicians
            ?.where((t) => t.id == technicianID)
            .firstOrNull
            ?.name ??
        'Technician'.tr;
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: DashboardTechnicianScr(
              technicianID: technicianID, trail: [...trail, name]),
        ),
      ),
    );
  }

  @override
  State<DashboardTechnicianScr> createState() => _DashboardTechnicianScrState();
}

class _DashboardTechnicianScrState extends State<DashboardTechnicianScr> {
  VisitStatus? _status;
  int? _bucket;
  DashboardPeriod? _lastPeriod;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardBloc>().state;
    final period = state.period;
    // A selected bar belongs to the old period's axis, so drop it.
    if (_lastPeriod != null && _lastPeriod != period) _bucket = null;
    _lastPeriod = period;
    final now = DateTime.now();
    final stat = DashboardMetrics.technicianStats(state.snapshot, period, now)
        .where((s) => s.technician.id == widget.technicianID)
        .firstOrNull;

    return GWidgetTourFlag(tour: AppTours.dashboardTechnician, child: GWidgetNaviBody(
      title: stat?.technician.name ?? 'Technician'.tr,
      body: stat == null
          ? Center(
              child: VisitDetailEmpty(
                  icon: Icons.person_off_rounded,
                  text: 'This technician no longer exists'.tr))
          : _body(stat, period),
    ));
  }

  Widget _body(DashboardTechnicianStat stat, DashboardPeriod period) {
    final technician = stat.technician;
    final status = TechnicianStatusSwitch(technicianStatusEnum: technician.status);
    final buckets = DashboardMetrics.visitTrend(stat.visits, period);
    final counts = DashboardMetrics.statusCounts(stat.visits);
    final statusList = VisitStatus.values.where((s) => counts[s]! > 0).toList();
    final bucket =
        _bucket == null || _bucket! >= buckets.length ? null : buckets[_bucket!];
    final filtered = stat.visits.where((v) {
      if (_status != null && (v.status ?? VisitStatus.draft) != _status) {
        return false;
      }
      if (bucket != null &&
          (v.startDate!.isBefore(bucket.from) ||
              !v.startDate!.isBefore(bucket.to))) {
        return false;
      }
      return true;
    }).toList();
    final hasFilter = _status != null || bucket != null;

    return ListView(
      cacheExtent: 100000, // keeps every section built for the guided tour
      padding: const EdgeInsets.only(top: 12, bottom: 32),
      children: [
        GTourTarget(id: 'trail', child: DashboardBreadcrumb(trail: widget.trail)),
        const SizedBox(height: 10),
        GTourTarget(id: 'period', child: DashboardWidgetPeriodBar(period: period)),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  VisitDetailAvatar(
                    letter: VisitDetailHelpers.initial(technician.name),
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(technician.name ?? 'Technician'.tr,
                            style: AppTheme.font(
                                color: AppTheme.textPrimary,
                                fontSize: AppTheme.textTitle,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            VisitDetailPill(
                                text: status.getText(), color: status.getColor()),
                            if (stat.activeNow > 0)
                              VisitDetailPill(
                                  text: '{0} active now'.trArgs([stat.activeNow]),
                                  color: AppTheme.primary,
                                  icon: Icons.bolt_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, TechnicianDetailScr.route,
                        arguments: TechnicianDetailArgu(
                                techID: technician.id ?? '')
                            .toArgu()),
                    child: Text('Profile'.tr,
                        style: AppTheme.font(
                            color: AppTheme.primary,
                            fontSize: AppTheme.textBody,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GTourTarget(id: 'stats', child: DashboardGrid(columns: 4, spacing: 8, children: [
                DashboardMiniStat(label: 'Visits'.tr, value: '${stat.visits.length}'),
                DashboardMiniStat(label: 'Completed'.tr, value: '${stat.completed}'),
                DashboardMiniStat(
                    label: 'Completion'.tr,
                    value: DashboardFormat.percent(stat.completionRate)),
                DashboardMiniStat(
                    label: 'Collected'.tr,
                    value: DashboardFormat.money(stat.collected)),
              ])),
              const SizedBox(height: 14),
              DashboardSection(
                title: 'Workload over time'.tr,
                subtitle: 'Tap a bar to list those visits'.tr,
                child: GTourTarget(id: 'chart', child: DashboardWidgetTrendChart(
                  buckets: buckets,
                  selectedIndex: _bucket,
                  onSelect: (index) => setState(() => _bucket = index),
                )),
              ),
              const SizedBox(height: 14),
              GTourTarget(id: 'status', child: DashboardSection(
                title: 'By status'.tr,
                child: statusList.isEmpty
                    ? Text('No visits in this period'.tr,
                        style: AppTheme.font(
                            color: AppTheme.textSecondary, fontSize: AppTheme.textBody))
                    : DashboardWidgetBarList(
                        items: [
                          for (final s in statusList)
                            DashboardBarItem(
                              label: VisitDetailHelpers.statusText(s),
                              value: counts[s]!,
                              valueLabel: '${counts[s]}',
                              color: VisitDetailHelpers.statusColor(s),
                              icon: VisitDetailHelpers.statusIcon(s),
                            ),
                        ],
                        selectedIndex:
                            _status == null ? null : statusList.indexOf(_status!),
                        onTap: (i) => setState(() => _status =
                            _status == statusList[i] ? null : statusList[i]),
                      ),
              )),
              const SizedBox(height: 14),
              GTourTarget(id: 'list', child: DashboardSection(
                title: '{0} visit{1}'.trArgs([filtered.length, filtered.length == 1 ? '' : 's']),
                subtitle: hasFilter ? 'Filtered selection'.tr : 'All in this period'.tr,
                actionText: hasFilter ? 'Clear filter'.tr : null,
                onAction: hasFilter
                    ? () => setState(() {
                          _status = null;
                          _bucket = null;
                        })
                    : null,
                child: DashboardWidgetVisitList(
                    visits: filtered,
                    emptyText: 'No visits match this selection'.tr),
              )),
            ],
          ),
        ),
      ],
    );
  }
}
