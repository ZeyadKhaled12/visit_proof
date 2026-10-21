import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_loading.dart';
import 'package:visit_proof/features/technicians/presentation/controller/tech_bloc.dart';

import '../../../../../configs/app_colors.dart';
import '../../../../../configs/app_fonts.dart';
import '../../../../../core/usecase/base_use_case.dart';
import '../../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../../core/utils/general_widgets/g_widget_excel.dart';
import '../../../../../core/utils/general_widgets/g_widget_floating_btn.dart';
import '../../../../../core/utils/general_widgets/g_widget_search.dart';
import '../../../data/models/technician_model.dart';
import '../../screens/add_tech_scr.dart';
import '../technicians_widget_card.dart';

class TechniciansBody extends StatelessWidget {
  const TechniciansBody(
      {super.key, required this.technicians, required this.loading});
  final List<TechnicianModel> technicians;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar:
            GWidgetAppbar(title: 'Technicians', icon: Icons.handyman, actions: [
          Center(
              child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: GWidgetExcel()))
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
                  hint: 'Search technicians...',
                  onChanged: (value) {},
                  onClear: () {},
                ),
                const SizedBox(height: 16),
                Expanded(
                    child: technicians.isEmpty && !loading
                        ? Center(
                            child: Text(
                              'No technicians yet!',
                              style: AppFonts(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: technicians.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: technicians.length - 1 == index
                                      ? EdgeInsets.only(bottom: 80)
                                      : EdgeInsets.zero,
                                  child: TechnicianWidgetCard(
                                      technician: technicians[index]));
                            },
                          )),
              ],
            ),
          ),
        ),
        floatingActionButton: GWidgetFloatingBtn(
            text: "Add new technician",
            onPressed: () async {
              final data = await Navigator.pushNamed(context, AddTechScr.route);
              if (data is bool) {
                if (data) {
                  context
                      .read<TechBloc>()
                      .add(GetTechniciansEvent(noParameters: NoParameters()));
                }
              }
            }));
  }
}
