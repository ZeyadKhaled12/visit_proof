import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/general_functions.dart/g_fun_search.dart';
import '../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../core/utils/general_widgets/g_widget_empty.dart';
import '../../../../core/utils/general_widgets/g_widget_search.dart';
import '../../../visit_detail/domain/rules/visit_rules.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../controller/dispatch_bloc.dart';
import 'dispatch_widget_action_sheet.dart';
import 'dispatch_widget_visit_card.dart';
import 'sheets/dispatch_widget_bulk_assign_sheet.dart';
import 'sheets/dispatch_widget_suggest_sheet.dart';

/// Visits waiting for a technician, with search and multi-select.
class DispatchWidgetQueue extends StatefulWidget {
  const DispatchWidgetQueue(
      {super.key, required this.visits, this.primary = true});
  final List<VisitDetailModel> visits;

  /// False when shown beside the board, so each list scrolls on its own.
  final bool primary;

  @override
  State<DispatchWidgetQueue> createState() => _DispatchWidgetQueueState();
}

class _DispatchWidgetQueueState extends State<DispatchWidgetQueue> {
  final TextEditingController _search = TextEditingController();
  final Set<String?> _selected = {};
  String _query = '';
  bool _selecting = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<VisitDetailModel> get _visible => widget.visits
      .where((v) => GFunSearch.matches(_query, [
            v.visitNumber,
            v.serviceName,
            v.client?.name,
            v.site?.city?.name,
            v.category?.name,
          ]))
      .toList();

  void _toggle(VisitDetailModel visit) => setState(() =>
      _selected.contains(visit.id)
          ? _selected.remove(visit.id)
          : _selected.add(visit.id));

  void _bulkAssign() {
    final visits =
        widget.visits.where((v) => _selected.contains(v.id)).toList();
    DispatchWidgetActionSheet.show(
        context, DispatchWidgetBulkAssignSheet(visitIDs: [
      for (final visit in visits) visit.id,
    ])).then((_) {
      if (mounted) setState(() => _selected.clear());
    });
  }

  @override
  Widget build(BuildContext context) {
    final day = context.select<DispatchBloc, DateTime>((b) => b.state.day);
    final visits = _visible;
    final assignable =
        visits.where(VisitRules.canAssignTechnician).map((v) => v.id).toSet();
    _selected.removeWhere((id) => !widget.visits.any((v) => v.id == id));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: GWidgetSearch(
                  hint: 'Search waiting visits...'.tr,
                  searchController: _search,
                  onChanged: (value) => setState(() => _query = value ?? ''),
                  onClear: () {
                    _search.clear();
                    setState(() => _query = '');
                  },
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => setState(() {
                  _selecting = !_selecting;
                  _selected.clear();
                }),
                child: Text(_selecting ? 'Done'.tr : 'Select'.tr,
                    style: AppTheme.font(
                        color: AppTheme.primary,
                        fontSize: AppTheme.textBody,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: visits.isEmpty
              ? SingleChildScrollView(
                  primary: widget.primary,
                  child: GWidgetEmpty(
                    icon: widget.visits.isEmpty
                        ? Icons.task_alt_rounded
                        : Icons.search_off_rounded,
                    title: widget.visits.isEmpty
                        ? 'Every visit has a technician'.tr
                        : 'No matching visits'.tr,
                    subtitle: widget.visits.isEmpty
                        ? 'New visits without a technician will wait here.'.tr
                        : 'Try another search.'.tr,
                  ),
                )
              : ListView.separated(
                  primary: widget.primary,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: visits.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final visit = visits[index];
                    final canAssign = assignable.contains(visit.id);
                    return _QueueRow(
                      visit: visit,
                      day: day,
                      selecting: _selecting,
                      selected: _selected.contains(visit.id),
                      canAssign: canAssign,
                      onSelect: canAssign ? () => _toggle(visit) : null,
                    );
                  },
                ),
        ),
        if (_selecting && _selected.isNotEmpty)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: GWidgetButton(
                text: 'Assign {0} visit{1}'.trArgs([_selected.length, _selected.length == 1 ? '' : 's']),
                fontSize: AppTheme.textSubtitle,
                height: 50,
                raduis: 14,
                onPressed: _bulkAssign,
              ),
            ),
          ),
      ],
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.visit,
    required this.day,
    required this.selecting,
    required this.selected,
    required this.canAssign,
    required this.onSelect,
  });

  final VisitDetailModel visit;
  final DateTime day;
  final bool selecting;
  final bool selected;
  final bool canAssign;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (selecting)
          Checkbox(
            value: selected,
            activeColor: AppTheme.primary,
            onChanged: onSelect == null ? null : (_) => onSelect!(),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DispatchWidgetVisitCard(
                  visit: visit, day: day, draggable: !selecting && canAssign),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (!canAssign)
                    Expanded(
                      child: Text(
                          VisitRules.assignError(visit) ??
                              'Not ready to assign'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.font(
                              color: AppTheme.statOrange,
                              fontSize: AppTheme.textCaption,
                              fontWeight: FontWeight.w600)),
                    )
                  else
                    const Spacer(),
                  if (canAssign && !selecting)
                    TextButton.icon(
                      onPressed: () => DispatchWidgetActionSheet.show(context,
                          DispatchWidgetSuggestSheet(visitID: visit.id)),
                      icon: Icon(Icons.auto_awesome_rounded,
                          size: 16, color: AppTheme.primary),
                      label: Text('Suggest technician'.tr,
                          style: AppTheme.font(
                              color: AppTheme.primary,
                              fontSize: AppTheme.textSmall,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
