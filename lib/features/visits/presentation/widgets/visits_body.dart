import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/add_visit/presentation/screens/add_visit_scr.dart';
import 'package:visit_proof/features/visits/presentation/controller/visits_bloc.dart';

import '../../../../configs/app_theme.dart';
import '../../../../configs/app_toasts.dart';
import '../../../../core/utils/general_functions.dart/g_fun_search.dart';
import '../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../dispatch/presentation/screens/dispatch_scr.dart';
import '../../../main_menu/presentation/screens/main_menu_scr.dart';
import '../../../main_menu/presentation/widgets/main_menu_tabs.dart';
import '../../../../core/utils/general_widgets/g_widget_empty.dart';
import '../../../../core/utils/general_widgets/g_widget_floating_btn.dart';
import '../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../data/models/visit_detail_models/visit_detail_model.dart';
import 'visits_widget_card.dart';
import 'visits_widget_filter_sheet.dart';
import 'visits_widget_filters.dart';

class VisitsBody extends StatefulWidget {
  const VisitsBody({super.key, required this.visits, required this.loading});
  final List<VisitDetailModel> visits;
  final bool loading;

  @override
  State<VisitsBody> createState() => _VisitsBodyState();
}

class _VisitsBodyState extends State<VisitsBody> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  VisitsFilter _filter = const VisitsFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VisitDetailModel> get _visibleVisits => widget.visits
      .where((visit) =>
          _filter.matches(visit) &&
          GFunSearch.matches(_query, [
            visit.visitNumber,
            visit.serviceName,
            visit.category?.name,
            visit.client?.name,
            visit.client?.phone,
            visit.technicianModel?.name,
            visit.site?.city?.name,
            visit.site?.addressDetail,
          ]))
      .toList();

  void _refresh() =>
      context.read<VisitsBloc>().add(GetVisitsEvent(noParameters: NoParameters()));

  Future<void> _addVisit() async {
    final data = await Navigator.pushNamed(context, AddVisitScr.route);
    if (data == true && mounted) _refresh();
  }

  Future<void> _openDispatch() async {
    if (MainMenuScr.open(context, MainMenuTab.dispatch)) return;
    await Navigator.pushNamed(context, DispatchScr.route);
    if (mounted) _refresh();
  }

  Future<void> _openFilters() async {
    final data = await AppToasts.showBottomSheet(
        context, VisitsWidgetFilterSheet(filter: _filter));
    if (data is VisitsFilter) setState(() => _filter = data);
  }

  void _clearSearchAndFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = const VisitsFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visits = _visibleVisits;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: GWidgetAppbar(
          title: 'Visits'.tr,
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: GWidgetButton(
                text: 'Dispatch'.tr,
                fontSize: AppTheme.textBody,
                height: 38,
                raduis: 12,
                paddingTopBottom: 0,
                paddingLeftRight: 12,
                widget: Padding(
                  padding: EdgeInsetsDirectional.only(start: 6),
                  child: Icon(Icons.hub_rounded,
                      size: 16, color: AppTheme.onPrimary),
                ),
                onPressed: _openDispatch,
              ),
            ),
          ]).appbar(),
      floatingActionButton:
          GWidgetFloatingBtn(text: 'Add New Visit'.tr, onPressed: _addVisit),
      body: GWidgetLoading(
        isLoading: widget.loading,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 5),
              VisitsWidgetFilters(
                searchController: _searchController,
                onSearch: (value) => setState(() => _query = value),
                activeFilters: _filter.activeCount,
                onFilter: _openFilters,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () async => _refresh(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 140),
                    itemCount: visits.isEmpty ? 1 : visits.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (visits.isEmpty) return _emptyState();
                      return VisitsWidgetCard(
                          visit: visits[index], onReturn: _refresh);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    if (widget.loading) return const SizedBox.shrink();

    if (widget.visits.isEmpty) {
      return GWidgetEmpty(
        icon: Icons.event_note_rounded,
        title: 'No visits yet'.tr,
        subtitle: 'Create your first visit to start tracking field work.'.tr,
        actionText: 'Add first visit'.tr,
        onAction: _addVisit,
      );
    }

    return GWidgetEmpty(
      icon: Icons.search_off_rounded,
      title: 'No matching visits'.tr,
      subtitle: 'Try another search or clear the filters.'.tr,
      actionText: 'Clear search & filters'.tr,
      onAction: _clearSearchAndFilters,
    );
  }
}
