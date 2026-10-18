import 'package:flutter/material.dart';
import '../../../../configs/app_colors.dart';
import '../../../../core/utils/general_models/g_model_catg.dart';
import '../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../core/utils/general_widgets/g_widget_excel.dart';
import '../../../../core/utils/general_widgets/g_widget_floating_btn.dart';
import '../../../../core/utils/general_widgets/g_widget_search.dart';
import '../../data/models/service_model.dart';
import '../widgets/services_widget_card.dart';

class ServicesScr extends StatelessWidget {
  const ServicesScr({super.key});

  @override
  Widget build(BuildContext context) {
    List<ServiceModel> services = [
      ServiceModel(
        category: GModelCatg(id: '2', name: 'Plumbing'),
        serviceName: 'Water Heater Inspection',
        defaultPrice: 85.50,
        checkList: [
          'Check for leaks',
          'Flush tank to remove sediment',
          'Inspect pressure relief valve'
        ],
      ),
      ServiceModel(
        category: GModelCatg(id: '2', name: 'Plumbing'),
        serviceName: 'Water Heater Inspection',
        defaultPrice: 85.50,
        checkList: [
          'Check for leaks',
          'Flush tank to remove sediment',
          'Inspect pressure relief valve'
        ],
      ),
      ServiceModel(
        category: GModelCatg(id: '2', name: 'Plumbing'),
        serviceName: 'Water Heater Inspection',
        defaultPrice: 85.50,
        checkList: [
          'Check for leaks',
          'Flush tank to remove sediment',
          'Inspect pressure relief valve'
        ],
      ),
      ServiceModel(
          category: GModelCatg(id: '2', name: 'Plumbing'),
          serviceName: 'Water Heater Inspection',
          defaultPrice: 85.50)
    ];
    return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: GWidgetAppbar(
            title: 'Services',
            icon: Icons.miscellaneous_services,
            actions: [
              Center(
                child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GWidgetExcel()),
              ),
            ]).appbar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 5),
              GWidgetSearch(
                searchController: TextEditingController(),
                hint: 'Search services...',
                onChanged: (value) {},
                onClear: () {},
              ),
              const SizedBox(height: 16),
              Expanded(
                  child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: services.length - 1 == index
                        ? EdgeInsets.only(bottom: 80)
                        : EdgeInsets.zero,
                    child: ServicesWidgetCard(service: services[index]),
                  );
                },
              ))
              //       : Center(
              //           child: Text(
              //             'No technicians match your search.',
              //             style: AppFonts(color: Colors.grey, fontSize: 16),
              //           ),
              //         ),
              // ),
            ],
          ),
        ),
        floatingActionButton: GWidgetFloatingBtn(
            text: "Add new service",
            onPressed: () async {
              // await Navigator.pushNamed(context, AddClientScr.route);
            }));
  }
}
