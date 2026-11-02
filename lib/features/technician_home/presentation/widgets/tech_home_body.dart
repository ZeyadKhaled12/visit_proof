import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../core/utils/general_widgets/g_widget_choice_chip.dart';
import '../../../../core/utils/general_widgets/g_widget_empty.dart';
import '../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../visit_detail/presentation/screens/visit_detail_scr.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../visits/presentation/controller/visits_bloc.dart';
import '../../../visits/presentation/widgets/visits_widget_card.dart';

/// Which of the technician's visits are listed.
enum TechVisitsFilter {
  open('Open'),
  today('Today'),
  completed('Completed'),
  all('All');

  const TechVisitsFilter(this._label);
  final String _label;
  String get label => _label.tr;

  bool matches(VisitDetailModel visit) {
    final status = visit.status;
    switch (this) {
      case TechVisitsFilter.open:
        return status == VisitStatus.assigned ||
            status == VisitStatus.onWay ||
            status == VisitStatus.inProgress;
      case TechVisitsFilter.today:
        return DateUtils.isSameDay(visit.startDate, DateTime.now());
      case TechVisitsFilter.completed:
        return status == VisitStatus.completed;
      case TechVisitsFilter.all:
        return true;
    }
  }

  /// Upcoming work soonest first; finished work newest first.
  int compare(VisitDetailModel a, VisitDetailModel b) {
    final first = a.startDate ?? DateTime(0);
    final second = b.startDate ?? DateTime(0);
    return this == TechVisitsFilter.open || this == TechVisitsFilter.today
        ? first.compareTo(second)
        : second.compareTo(first);
  }
}

class TechHomeBody extends StatefulWidget {
  const TechHomeBody({super.key, required this.visits, required this.loading});
  final List<VisitDetailModel> visits;
  final bool loading;

  @override
  State<TechHomeBody> createState() => _TechHomeBodyState();
}

class _TechHomeBodyState extends State<TechHomeBody> {
  TechVisitsFilter _filter = TechVisitsFilter.open;

  void _refresh() => context
      .read<VisitsBloc>()
      .add(const GetVisitsEvent(noParameters: NoParameters()));

  Future<void> _open(VisitDetailModel visit) async {
    if (visit.id == null) return;
    await Navigator.pushNamed(context, VisitDetailScr.route,
        arguments: VisitDetailArgu(visitID: visit.id!).toArgu());
    if (mounted) _refresh();
  }

  int _count(TechVisitsFilter filter) =>
      widget.visits.where(filter.matches).length;

  @override
  Widget build(BuildContext context) {
    final visits = widget.visits.where(_filter.matches).toList()
      ..sort(_filter.compare);
    final active = widget.visits
        .where((e) =>
            e.status == VisitStatus.onWay || e.status == VisitStatus.inProgress)
        .toList()
      ..sort(TechVisitsFilter.open.compare);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: GWidgetAppbar(
              title: 'My Visits'.tr, icon: Icons.engineering_outlined)
          .appbar(),
      body: GWidgetLoading(
        isLoading: widget.loading,
        body: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async => _refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              _Greeting(openCount: _count(TechVisitsFilter.open)),
              if (active.isNotEmpty) ...[
                const SizedBox(height: 14),
                _ActiveJob(visit: active.first, onTap: () => _open(active.first)),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final filter in TechVisitsFilter.values)
                    GWidgetChoiceChip(
                      label: '{0} ({1})'.trArgs([filter.label, _count(filter)]),
                      color: AppTheme.primary,
                      selected: filter == _filter,
                      onTap: () => setState(() => _filter = filter),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (visits.isEmpty && !widget.loading)
                GWidgetEmpty(
                  icon: Icons.event_available_rounded,
                  title: widget.visits.isEmpty
                      ? 'No visits assigned to you yet'.tr
                      : 'Nothing in this list'.tr,
                  subtitle: widget.visits.isEmpty
                      ? 'Your admin assigns visits to you. Pull down to refresh.'.tr
                      : 'Try another filter.'.tr,
                ),
              for (final visit in visits) ...[
                VisitsWidgetCard(visit: visit, onReturn: _refresh),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.openCount});
  final int openCount;

  @override
  Widget build(BuildContext context) {
    final name = AppSession.current.value?.technicianName ?? '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.secondary],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hi, {0}'.trArgs([name]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.font(
                        color: AppTheme.onPrimary,
                        fontSize: AppTheme.textTitleLarge,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                    style: AppTheme.font(
                        color: AppTheme.onPrimary.withValues(alpha: .85),
                        fontSize: AppTheme.textSmall,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            children: [
              Text('$openCount',
                  style: AppTheme.font(
                      color: AppTheme.onPrimary,
                      fontSize: AppTheme.textHeadline,
                      fontWeight: FontWeight.w800)),
              Text('open visits'.tr,
                  style: AppTheme.font(
                      color: AppTheme.onPrimary.withValues(alpha: .85),
                      fontSize: AppTheme.textCaption,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

/// The visit the technician is travelling to or working on right now.
class _ActiveJob extends StatelessWidget {
  const _ActiveJob({required this.visit, required this.onTap});
  final VisitDetailModel visit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = VisitDetailHelpers.statusColor(visit.status);

    return Material(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: .5)),
          ),
          child: Row(
            children: [
              Icon(
                  VisitDetailHelpers.statusIcon(
                      visit.status ?? VisitStatus.onWay),
                  color: color,
                  size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current job · {0}'.trArgs(
                            [VisitDetailHelpers.statusText(visit.status)]),
                        style: AppTheme.font(
                            color: color,
                            fontSize: AppTheme.textSmall,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                        [visit.serviceName, visit.client?.name]
                            .where((e) => (e ?? '').isNotEmpty)
                            .join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.font(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.textBodyLarge,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
