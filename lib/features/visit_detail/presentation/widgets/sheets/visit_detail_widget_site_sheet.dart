import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_theme.dart';
import '../../../../../configs/app_toasts.dart';
import '../../../../../core/utils/general_models/g_model_site.dart';
import '../../../../../core/utils/general_widgets/g_widget_add_btn.dart';
import '../../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../../add_visit/presentation/widgets/add_visit_widget_site_sheet.dart';
import '../../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../domain/usecases/change_visit_site_uc.dart';
import '../../controller/visit_detail_bloc.dart';
import '../visit_detail_helpers.dart';
import '../visit_detail_widget_action_sheet.dart';
import '../visit_detail_widget_parts.dart';

class VisitDetailWidgetSiteSheet extends StatefulWidget {
  const VisitDetailWidgetSiteSheet({super.key, required this.visit});
  final VisitDetailModel visit;

  @override
  State<VisitDetailWidgetSiteSheet> createState() =>
      _VisitDetailWidgetSiteSheetState();
}

class _VisitDetailWidgetSiteSheetState
    extends State<VisitDetailWidgetSiteSheet> {
  late final List<GModelSite> _sites = [...?widget.visit.client?.sites];
  GModelSite? _selected;

  Future<void> _addSite() async {
    final site =
        await AppToasts.showBottomSheet(context, const AddVisitWidgetSiteSheet());
    if (site is GModelSite) {
      setState(() {
        _sites.add(site);
        _selected = site;
      });
    }
  }

  void _submit() {
    context.read<VisitDetailBloc>().add(ChangeVisitSiteEvent(
        changeVisitSiteParameters: ChangeVisitSiteParameters(
            visitID: widget.visit.id!, site: _selected!)));
  }

  @override
  Widget build(BuildContext context) {
    return VisitDetailWidgetActionSheet(
      title: 'Change site'.tr,
      subtitle: 'Current: {0}'.trArgs([VisitDetailHelpers.site(widget.visit.site)]),
      requestState: (state) => state.changeSiteRequestState,
      builder: (context, state, loading) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GWidgetDropDown<GModelSite>(
            labelText: 'Site'.tr,
            value: _selected,
            prefixIcon:
                Icon(Icons.location_on_rounded, color: AppTheme.statOrange),
            onChanged: (site) => setState(() => _selected = site),
            items: _sites
                .map((site) => DropdownMenuItem(
                      value: site,
                      child: Text(VisitDetailHelpers.site(site),
                          style: AppTheme.font(fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GWidgetAddBtn(text: 'Add new site'.tr, onTap: _addSite),
          ),
          const SizedBox(height: 10),
          VisitDetailNotice(
              text: 'A draft invoice keeps a copy of the site, so it is updated too. Issued invoices are not changed.'.tr,
              color: AppTheme.secondary),
          const SizedBox(height: 16),
          GWidgetButton(
            text: 'Save site'.tr,
            fontSize: AppTheme.textSubtitle,
            raduis: 14,
            backgroundColor: AppTheme.secondary,
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
