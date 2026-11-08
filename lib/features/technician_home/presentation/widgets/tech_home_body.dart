import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../core/utils/general_widgets/g_widget_choice_chip.dart';
import '../../../../core/utils/general_widgets/g_widget_empty.dart';
import '../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../visit_detail/presentation/screens/visit_detail_scr.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_helpers.dart';
import '../../../visit_detail/presentation/widgets/visit_detail_widget_parts.dart';
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

  /// The header, then the visit cards, built only as they scroll into view.
  Widget _list(List<VisitDetailModel> active, List<VisitDetailModel> visits) {
    final header = <Widget>[
      _Greeting(
          openCount: _count(TechVisitsFilter.open),
          todayCount: _count(TechVisitsFilter.today)),
      if (active.isNotEmpty) ...[
        const SizedBox(height: 16),
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
    ];

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: header.length + visits.length,
      itemBuilder: (context, index) {
        if (index < header.length) return header[index];
        final visit = visits[index - header.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: VisitsWidgetCard(visit: visit, onReturn: _refresh),
        );
      },
    );
  }

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
              title: 'My Visits'.tr, )
          .appbar(),
      body: GWidgetLoading(
        isLoading: widget.loading,
        body: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async => _refresh(),
          child: _list(active, visits),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.openCount, required this.todayCount});
  final int openCount;
  final int todayCount;

  @override
  Widget build(BuildContext context) {
    final name = AppSession.current.value?.technicianName ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
            style: AppTheme.font(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.textSmall,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text('Hi, {0}'.trArgs([name]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.font(
                color: AppTheme.textPrimary,
                fontSize: AppTheme.textHeadline,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(
            'You have {0} open visits · {1} today'
                .trArgs([openCount, todayCount]),
            style: AppTheme.font(
                color: AppTheme.textSecondary, fontSize: AppTheme.textBody)),
      ],
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
    final place = [
      visit.site?.city?.name?.tr,
      visit.site?.addressDetail,
    ].where((e) => (e ?? '').isNotEmpty).join(' - ');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Right now'.tr,
                    style: AppTheme.font(
                        color: color,
                        fontSize: AppTheme.textSmall,
                        fontWeight: FontWeight.w800)),
              ),
              VisitDetailPill(
                text: VisitDetailHelpers.statusText(visit.status),
                color: color,
                icon: VisitDetailHelpers.statusIcon(
                    visit.status ?? VisitStatus.onWay),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(visit.client?.name ?? 'no client'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.font(
                  color: AppTheme.textPrimary,
                  fontSize: AppTheme.textTitleLarge,
                  fontWeight: FontWeight.w800)),
          if ((visit.serviceName ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(visit.serviceName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.font(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.textBody)),
          ],
          if (place.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(place,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.font(
                    color: AppTheme.textDarkHint,
                    fontSize: AppTheme.textSmall)),
          ],
          const SizedBox(height: 14),
          GWidgetButton(
            text: 'Open visit details'.tr,
            fontSize: AppTheme.textSubtitle,
            height: 56,
            paddingTopBottom: 0,
            backgroundColor: color,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
