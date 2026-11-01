import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/enums/visit_status_enum.dart';
import '../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../core/utils/general_widgets/g_widget_empty.dart';
import '../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../technicians/presentation/screens/add_tech_scr.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/rules/dispatch_rules.dart';
import '../controller/dispatch_bloc.dart';
import 'dispatch_widget_action_sheet.dart';
import 'dispatch_widget_date_strip.dart';
import 'dispatch_widget_kpis.dart';
import 'dispatch_widget_map.dart';
import 'dispatch_widget_queue.dart';
import 'dispatch_widget_technician_card.dart';
import 'dispatch_widget_unassigned_tray.dart';
import 'sheets/dispatch_widget_settings_sheet.dart';
import 'sheets/dispatch_widget_visit_list_sheet.dart';

enum DispatchView { technicians, queue, map }

class DispatchBody extends StatefulWidget {
  const DispatchBody({super.key, required this.state});
  final DispatchState state;

  @override
  State<DispatchBody> createState() => _DispatchBodyState();
}

class _DispatchBodyState extends State<DispatchBody> {
  /// Wide screens (tablets) show the queue next to the technicians.
  static const double _wideBreakpoint = 900;

  DispatchView _view = DispatchView.technicians;

  void _reload() => context
      .read<DispatchBloc>()
      .add(const GetDispatchBoardEvent(noParameters: NoParameters()));

  Future<void> _addTechnician() async {
    await Navigator.pushNamed(context, AddTechScr.route);
    if (mounted) _reload();
  }

  void _showList(String title, List<VisitDetailModel> visits) =>
      DispatchWidgetActionSheet.show(
          context,
          DispatchWidgetVisitListSheet(
              title: title, visitIDs: visits.map((v) => v.id).toList()));

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final day = state.day;
    final now = DateTime.now();
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    final unassigned = DispatchRules.unassigned(state.visits);
    final conflicts = DispatchRules.conflicts(
        visits: state.visits, daysOff: state.daysOff, day: day);
    final late = state.visits.where((v) => DispatchRules.isLate(v, now)).toList();
    final dayVisits = state.visits
        .where((v) =>
            DispatchRules.sameDay(v.startDate, day) &&
            v.status != VisitStatus.cancel)
        .toList();

    if (wide && _view == DispatchView.queue) _view = DispatchView.technicians;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: GWidgetAppbar(title: 'Dispatch'.tr, icon: Icons.hub_rounded, actions: [
        IconButton(
          tooltip: 'Dispatch rules'.tr,
          icon: Icon(Icons.tune_rounded, color: AppTheme.primary),
          onPressed: () => DispatchWidgetActionSheet.show(
              context, const DispatchWidgetSettingsSheet()),
        ),
        const SizedBox(width: 8),
      ]).appbar(),
      body: GWidgetLoading(
        isLoading: state.getBoardRequestState == RequestState.loading,
        body: Column(
          children: [
            // The date strip and counters scroll away with the content and
            // the view switch stays pinned, so short screens never overflow.
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        DispatchWidgetDateStrip(
                          day: day,
                          visits: state.visits,
                          onChanged: (date) => context
                              .read<DispatchBloc>()
                              .add(ChangeDispatchDateEvent(date: date)),
                        ),
                        const SizedBox(height: 10),
                        DispatchWidgetKpis(
                          unassigned: unassigned.length,
                          conflicts: conflicts.length,
                          late: late.length,
                          planned: dayVisits.length,
                          onUnassigned: () => wide
                              ? _showList('Waiting for a technician'.tr, unassigned)
                              : setState(() => _view = DispatchView.queue),
                          onConflicts: () =>
                              _showList('Conflicts on this day'.tr, conflicts),
                          onLate: () => _showList('Late visits'.tr, late),
                          onPlanned: () =>
                              _showList('Visits on this day'.tr, dayVisits),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PinnedHeader(
                      height: 60 * MediaQuery.textScalerOf(context).scale(1),
                      child: _ViewSwitch(
                        view: _view,
                        showQueue: !wide,
                        queueCount: unassigned.length,
                        onChanged: (view) => setState(() => _view = view),
                      ),
                    ),
                  ),
                ],
                body: _content(state, unassigned, dayVisits, wide),
              ),
            ),
            if (_view == DispatchView.technicians &&
                !wide &&
                state.technicians.isNotEmpty)
              DispatchWidgetUnassignedTray(visits: unassigned, day: day),
          ],
        ),
      ),
    );
  }

  Widget _content(
    DispatchState state,
    List<VisitDetailModel> unassigned,
    List<VisitDetailModel> dayVisits,
    bool wide,
  ) {
    switch (_view) {
      case DispatchView.queue:
        return DispatchWidgetQueue(visits: unassigned);
      case DispatchView.map:
        return DispatchWidgetMap(visits: [
          ...dayVisits,
          ...unassigned
              .where((v) => !DispatchRules.sameDay(v.startDate, state.day)),
        ]);
      case DispatchView.technicians:
        final board = _technicianBoard(state);
        if (!wide) return board;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
                width: 360,
                // Its own scroll, so it doesn't share the board's controller.
                child: DispatchWidgetQueue(visits: unassigned, primary: false)),
            VerticalDivider(
                width: 1, color: AppTheme.iconLightGrey.withValues(alpha: .4)),
            Expanded(child: board),
          ],
        );
    }
  }

  Widget _technicianBoard(DispatchState state) {
    if (state.technicians.isEmpty) {
      if (state.getBoardRequestState == RequestState.loading) {
        return const SizedBox.shrink();
      }
      return SingleChildScrollView(
        child: GWidgetEmpty(
          icon: Icons.engineering_rounded,
          title: 'No technicians yet'.tr,
          subtitle: 'Add technicians to start dispatching visits.'.tr,
          actionText: 'Add technician'.tr,
          onAction: _addTechnician,
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async => _reload(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: state.technicians.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => DispatchWidgetTechnicianCard(
            technician: state.technicians[index], state: state),
      ),
    );
  }
}

class _ViewSwitch extends StatelessWidget {
  const _ViewSwitch({
    required this.view,
    required this.showQueue,
    required this.queueCount,
    required this.onChanged,
  });

  final DispatchView view;
  final bool showQueue;
  final int queueCount;
  final ValueChanged<DispatchView> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [
      (DispatchView.technicians, 'Technicians'.tr, Icons.engineering_rounded),
      if (showQueue)
        (DispatchView.queue, 'Queue ({0})'.trArgs([queueCount]), Icons.inbox_rounded),
      (DispatchView.map, 'Map'.tr, Icons.map_rounded),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppTheme.shadowColor, blurRadius: 8)],
      ),
      child: Row(
        children: [
          for (final (value, label, icon) in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    gradient: view == value
                        ? LinearGradient(
                            colors: [AppTheme.primary, AppTheme.secondary])
                        : null,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon,
                          size: 16,
                          color: view == value
                              ? AppTheme.onPrimary
                              : AppTheme.iconGrey),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(label,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.font(
                                color: view == value
                                    ? AppTheme.onPrimary
                                    : AppTheme.textSecondary,
                                fontSize: AppTheme.textSmall,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Keeps the view switch visible while the header above it scrolls away.
class _PinnedHeader extends SliverPersistentHeaderDelegate {
  _PinnedHeader({required this.height, required this.child});
  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.scaffoldBackground,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_PinnedHeader oldDelegate) => true;
}
