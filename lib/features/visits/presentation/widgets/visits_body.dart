import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/add_visit/presentation/screens/add_visit_scr.dart';
import 'package:visit_proof/features/visits/presentation/controller/visits_bloc.dart';

import '../../../../configs/app_colors.dart';
import '../../../../core/utils/general_widgets/g_widget_appbar.dart';
import '../../../../core/utils/general_widgets/g_widget_excel.dart';
import '../../../../core/utils/general_widgets/g_widget_floating_btn.dart';
import '../../../../core/utils/general_widgets/g_widget_loading.dart';
import '../../data/models/visit_detail_models/visit_detail_model.dart';
import 'visits_widget_card.dart';
import 'visits_widget_filters.dart';

class VisitsBody extends StatelessWidget {
  const VisitsBody({super.key, required this.visits, required this.loading});
  final List<VisitDetailModel> visits;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: GWidgetAppbar(
          title: 'Visits',
          icon: Icons.fact_check_outlined,
          actions: [
            Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: GWidgetExcel()),
            ),
          ]).appbar(),
      floatingActionButton: GWidgetFloatingBtn(
          text: 'Add New Visit',
          onPressed: () async {
            final data = await Navigator.pushNamed(context, AddVisitScr.route);
            if (data is bool) {
              if (data) {
                context
                    .read<VisitsBloc>()
                    .add(GetVisitsEvent(noParameters: NoParameters()));
              }
            }
          }),
      body: GWidgetLoading(
        isLoading: loading,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 5),
              VisitsWidgetFilters(),
              SizedBox(height: 16),
              Expanded(
                  child: Container(
                color: AppColors.scaffoldBackground,
                child: ListView.separated(
                  itemCount: visits.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: index == visits.length - 1
                            ? EdgeInsets.only(bottom: 140)
                            : EdgeInsets.zero,
                        child: VisitsWidgetCard(visit: visits[index]));
                  },
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
