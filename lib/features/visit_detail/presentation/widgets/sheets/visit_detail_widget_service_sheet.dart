import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../core/usecase/base_use_case.dart';
import '../../../../../core/utils/enums.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../../services/data/models/service_model.dart';
import '../../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../domain/usecases/change_visit_service_uc.dart';
import '../../controller/visit_detail_bloc.dart';
import '../visit_detail_helpers.dart';
import '../visit_detail_widget_action_sheet.dart';
import '../visit_detail_widget_parts.dart';

class VisitDetailWidgetServiceSheet extends StatefulWidget {
  const VisitDetailWidgetServiceSheet({super.key, required this.visit});
  final VisitDetailModel visit;

  @override
  State<VisitDetailWidgetServiceSheet> createState() =>
      _VisitDetailWidgetServiceSheetState();
}

class _VisitDetailWidgetServiceSheetState
    extends State<VisitDetailWidgetServiceSheet> {
  ServiceModel? _selected;

  @override
  void initState() {
    super.initState();
    context
        .read<VisitDetailBloc>()
        .add(const GetVisitServicesEvent(noParameters: NoParameters()));
  }

  void _submit() {
    context.read<VisitDetailBloc>().add(ChangeVisitServiceEvent(
        changeVisitServiceParameters: ChangeVisitServiceParameters(
            visitID: widget.visit.id!, service: _selected!)));
  }

  @override
  Widget build(BuildContext context) {
    return VisitDetailWidgetActionSheet(
      title: 'Change service'.tr,
      subtitle: 'Current: {0}'.trArgs([widget.visit.serviceName ?? 'none'.tr]),
      requestState: (state) => state.changeServiceRequestState,
      builder: (context, state, loading) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GWidgetDropDown<ServiceModel>(
            labelText: 'Service'.tr,
            enableSearch: true,
            searchHintText: 'Search for a service'.tr,
            loading: state.getServicesRequestState == RequestState.loading,
            value: _selected,
            onChanged: (service) => setState(() => _selected = service),
            items: state.services
                .where((e) => e.serviceName != widget.visit.serviceName)
                .map((service) => DropdownMenuItem(
                      value: service,
                      child: Text(service.serviceName ?? '',
                          style: AppTheme.font(fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
          if (_selected != null) ...[
            const SizedBox(height: 14),
            _PriceChange(
                from: widget.visit.price, to: _selected!.defaultPrice),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: VisitDetailStatTile(
                      icon: Icons.timelapse_rounded,
                      label: 'Duration'.tr,
                      value: VisitDetailHelpers.duration(_selected!.duration),
                      color: AppTheme.statOrange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: VisitDetailStatTile(
                      icon: Icons.checklist_rounded,
                      label: 'Tasks'.tr,
                      value: '${_selected!.checkList?.length ?? 0}',
                      color: AppTheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            VisitDetailNotice(
                text: 'The draft invoice is repriced: discount and tax stay the same, the total follows the new price.'.tr,
                color: AppTheme.primary,
                icon: Icons.receipt_long_rounded),
          ],
          const SizedBox(height: 16),
          GWidgetButton(
            text: 'Change service'.tr,
            fontSize: AppTheme.textSubtitle,
            raduis: 14,
            isEnable: _selected != null,
            isLoading: loading,
            loadingSize: 22,
            loadingStrokeWidth: 3,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _PriceChange extends StatelessWidget {
  const _PriceChange({required this.from, required this.to});
  final num? from;
  final num? to;

  @override
  Widget build(BuildContext context) {
    final up = (to ?? 0) > (from ?? 0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.statGreen.withValues(alpha: .12),
          AppTheme.secondary.withValues(alpha: .08),
        ]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(VisitDetailHelpers.money(from),
                style: AppTheme.font(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.textBodyLarge,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.lineThrough)),
          ),
          Icon(up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              color: up ? AppTheme.statOrange : AppTheme.statGreen),
          Expanded(
            child: Text(VisitDetailHelpers.money(to),
                textAlign: TextAlign.end,
                style: AppTheme.font(
                    color: AppTheme.statGreen,
                    fontSize: AppTheme.textTitle,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
