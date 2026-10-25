import 'package:flutter/material.dart';

import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../../../core/utils/general_models/g_model_site.dart';
import '../../../../core/utils/general_widgets/g_widget_add_btn.dart';
import '../../../../core/utils/general_widgets/g_widget_button.dart';
import '../../../../core/utils/general_widgets/g_widget_card_title.dart';
import '../../../../core/utils/general_widgets/g_widget_drop_down.dart';
import '../../data/models/visit_client_model.dart';

final List<VisitClientModel> dummyVisitClients = [
  VisitClientModel(
    id: 'c_001',
    name: 'TechNova Solutions',
    phone: '+20 100 123 4567',
    isWhatsAppPhone: true,
    email: 'operations@technova.com',
    sites: [
      GModelSite(
        // Assuming GModelCatg has id and name, adjust to your actual model
        // city: GModelCatg(id: '1', name: 'Cairo'),
        addressDetail: 'Building 12, Smart Village, 6th of October',
        latitude: 30.0712,
        longitude: 31.0205,
      ),
      GModelSite(
        // city: GModelCatg(id: '2', name: 'Alexandria'),
        addressDetail: 'Stanly Bridge, Corniche Road',
        latitude: 31.2357,
        longitude: 29.9553,
      ),
    ],
    equipments: [], // Replace with actual GModelEquipment objects if needed
  ),
  VisitClientModel(
    id: 'c_002',
    name: 'Zaad Restaurant & Cafe',
    phone: '+20 111 987 6543',
    isWhatsAppPhone: false,
    email: 'info@zaad.com',
    sites: [
      GModelSite(
        // city: GModelCatg(id: '1', name: 'Cairo'),
        addressDetail: '90th Street, New Cairo',
        latitude: 30.0166,
        longitude: 31.4116,
      ),
    ],
    equipments: [],
  ),
  VisitClientModel(
    id: 'c_003',
    name: 'Ahmed Hassan',
    phone: '+20 122 345 6789',
    isWhatsAppPhone: true,
    email: 'ahmed.hassan@gmail.com',
    sites: [
      GModelSite(
        // city: GModelCatg(id: '1', name: 'Cairo'),
        addressDetail: 'Makram Ebeid St, Nasr City',
        latitude: 30.0626,
        longitude: 31.3366,
      ),
    ],
    equipments: null, // Testing a null equipment list
  ),
  VisitClientModel(
    id: 'c_004',
    name: 'Global Industries HQ',
    phone: '+20 155 555 9999',
    isWhatsAppPhone: false,
    email: null, // Testing a null email
    sites: [], // Testing an empty sites list
    equipments: [],
  ),
  VisitClientModel(
    id: 'c_005',
    name: 'Flowrista Operations',
    phone: '+20 100 000 1111',
    isWhatsAppPhone: true,
    email: 'dispatch@flowrista.com',
    sites: [
      GModelSite(
        // city: GModelCatg(id: '3', name: 'Giza'),
        addressDetail: 'Dokki Square, Giza',
        latitude: 30.0381,
        longitude: 31.2112,
      ),
    ],
    equipments: [],
  ),
];

class AddVisitWidgetClient extends StatelessWidget {
  const AddVisitWidgetClient(
      {super.key,
      this.selectedClient,
      this.selectedSite,
      required this.onClientChanged,
      required this.onSiteChanged});
  final VisitClientModel? selectedClient;
  final GModelSite? selectedSite;
  final Function(VisitClientModel? client) onClientChanged;
  final Function(GModelSite? site) onSiteChanged;

  @override
  Widget build(BuildContext context) {
    return GWidgetCardTitle(
        icon: Icons.person_pin_circle,
        title: 'Client & Site',
        child: Column(
          children: [
            GWidgetDropDown<VisitClientModel>(
              labelText: 'Client',
              enableSearch: true,
              value: selectedClient,
              onChanged: onClientChanged,
              items: dummyVisitClients.map((client) {
                return DropdownMenuItem(
                  value: client,
                  child: Text(client.name ?? '',
                      style: AppFonts(fontWeight: FontWeight.w500)),
                );
              }).toList(),
              searchHintText: 'Search for client',
            ),
            SizedBox(height: 10),
            GWidgetAddBtn(text: 'Add New Client', onTap: () {}),
            if (selectedClient != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GWidgetDropDown<GModelSite>(
                      labelText: 'Site',
                      onChanged: onSiteChanged,
                      items: (selectedClient?.sites ?? []).map((site) {
                        return DropdownMenuItem(
                          value: site,
                          child: Text(
                              '${site.city?.name ?? ''} - ${site.addressDetail ?? ''}',
                              style: AppFonts(fontWeight: FontWeight.w500)),
                        );
                      }).toList(),
                    ),
                  ),
                  if (selectedSite != null)
                    GWidgetButton(
                      backgroundColor: Colors.white,
                      text: 'Update\nSite',
                      colorText: AppColors.primary,
                      fontSize: 11,
                      onPressed: () {},
                    )
                ],
              ),
              SizedBox(height: 10),
              GWidgetAddBtn(text: 'Add New Site', onTap: () {})
            ],
          ],
        ));
  }
}
