import 'package:flutter/material.dart';
import 'package:visit_proof/configs/app_toasts.dart';
import 'package:visit_proof/features/clients/data/models/client_detail_model/client_detail_model.dart';
import 'package:visit_proof/features/clients/presentation/screens/add_client_scr.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/utils/general_models/g_model_site.dart';
import '../../../../core/utils/general_widgets/g_widget_add_btn.dart';
import '../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../core/utils/general_widgets/g_widget_card_title.dart';
import '../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../../visits/data/models/visit_detail_models/visit_client_model.dart';
import 'add_visit_widget_site_sheet.dart';

class AddVisitWidgetClient extends StatelessWidget {
  const AddVisitWidgetClient(
      {super.key,
      required this.clients,
      required this.sites,
      required this.loading,
      this.selectedClient,
      this.selectedSite,
      this.clientErrorMsg,
      this.siteErrorMsg,
      required this.onClientChanged,
      required this.onSiteChanged});
  final List<VisitClientModel> clients;
  final List<GModelSite> sites;
  final bool loading;
  final VisitClientModel? selectedClient;
  final GModelSite? selectedSite;
  final String? clientErrorMsg;
  final String? siteErrorMsg;
  final Function(VisitClientModel? client, {bool? isNewClient}) onClientChanged;
  final Function(GModelSite? site, {bool? isNewSite, int? index}) onSiteChanged;

  @override
  Widget build(BuildContext context) {
    return GWidgetCardTitle(
        icon: Icons.person_pin_circle,
        title: 'Client & Site',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GWidgetDropDown<VisitClientModel>(
              labelText: 'Client',
              enableSearch: true,
              errorMsg: clientErrorMsg,
              value: selectedClient,
              loading: loading,
              onChanged: onClientChanged,
              items: clients.map((client) {
                return DropdownMenuItem(
                  value: client,
                  child: Text(client.name ?? '',
                      style: AppTheme.font(fontWeight: FontWeight.w500)),
                );
              }).toList(),
              searchHintText: 'Search for client',
            ),
            SizedBox(height: 10),
            GWidgetAddBtn(
                text: 'Add New Client',
                onTap: () async {
                  final data = await Navigator.pushNamed(
                      context, AddClientScr.route,
                      arguments: AddClientArgu(returnClient: true).toArgu());
                  if (data is ClientDetailModel) {
                    onClientChanged(data.convertToVisitClient(),
                        isNewClient: true);
                  }
                }),
            if (selectedClient != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GWidgetDropDown<GModelSite>(
                      labelText: 'Site',
                      value: selectedSite,
                      errorMsg: siteErrorMsg,
                      onChanged: onSiteChanged,
                      items: sites.map((site) {
                        return DropdownMenuItem(
                          value: site,
                          child: Text(
                              '${site.city?.name ?? ''} - ${site.addressDetail ?? ''}',
                              style: AppTheme.font(fontWeight: FontWeight.w500)),
                        );
                      }).toList(),
                    ),
                  ),
                  if (selectedSite != null)
                    GWidgetButton(
                      backgroundColor: Colors.transparent,
                      text: 'Update\nSite',
                      colorText: AppTheme.primary,
                      fontSize: AppTheme.textCaption,
                      onPressed: () async {
                        final data = await AppToasts.showBottomSheet(
                            context,
                            AddVisitWidgetSiteSheet(
                              site: selectedSite,
                            ));
                        if (data is GModelSite) {
                          onSiteChanged(data,
                              index: sites.indexOf(selectedSite!));
                        }
                      },
                    )
                ],
              ),
              SizedBox(height: 10),
              GWidgetAddBtn(
                  text: 'Add New Site',
                  onTap: () async {
                    final data = await AppToasts.showBottomSheet(
                        context, AddVisitWidgetSiteSheet());
                    if (data is GModelSite) {
                      onSiteChanged(data, isNewSite: true);
                    }
                  })
            ],
          ],
        ));
  }
}
