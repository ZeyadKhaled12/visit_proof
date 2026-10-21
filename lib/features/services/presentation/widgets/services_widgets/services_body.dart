import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';
import '../../../../../core/usecase/base_use_case.dart';
import '../../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../../core/utils/general_widgets/g_widget_excel.dart';
import '../../../../../core/utils/general_widgets/g_widget_floating_btn.dart';
import '../../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../../../../core/utils/general_widgets/g_widget_search.dart';
import '../../../data/models/service_model.dart';
import '../../controller/services_bloc.dart';
import '../../screens/add_service_scr.dart';
import 'services_widget_card.dart';

class ServicesBody extends StatelessWidget {
  const ServicesBody(
      {super.key, required this.services, required this.loading});
  final List<ServiceModel> services;
  final bool loading;

  @override
  Widget build(BuildContext context) {
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
        body: GWidgetLoading(
          isLoading: loading,
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
                    child: services.isEmpty && !loading
                        ? Center(
                            child: Text(
                              'No services yet!',
                              style: AppFonts(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: services.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: services.length - 1 == index
                                    ? EdgeInsets.only(bottom: 80)
                                    : EdgeInsets.zero,
                                child: ServicesWidgetCard(
                                    service: services[index]),
                              );
                            },
                          ))
              ],
            ),
          ),
        ),
        floatingActionButton: GWidgetFloatingBtn(
            text: "Add new service",
            onPressed: () async {
              final data = await AddServiceScr.show(context);
              if (data is bool) {
                if (data) {
                  context
                      .read<ServicesBloc>()
                      .add(GetServicesEvent(noParameters: NoParameters()));
                }
              }
            }));
  }
}
