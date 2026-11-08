import 'package:visit_proof/configs/app_tours.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_theme.dart';
import '../../../../core/services/services_locator.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums.dart';
import '../../../visits/presentation/controller/visits_bloc.dart';
import '../widgets/tech_home_body.dart';
import '../widgets/tech_home_widget_drawer.dart';

/// The technician app: the visits assigned to the signed-in technician.
/// The visits data source already limits the list to their own visits.
class TechHomeScr extends StatelessWidget {
  const TechHomeScr({super.key});
  static const route = '/TechHomeScr';

  @override
  Widget build(BuildContext context) {
    return GWidgetTourFlag(tour: AppTours.technicianHome, child: Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      drawer: const TechHomeWidgetDrawer(),
      body: BlocProvider(
          create: (context) => sl<VisitsBloc>()
            ..add(const GetVisitsEvent(noParameters: NoParameters())),
          child: BlocBuilder<VisitsBloc, VisitsState>(
            builder: (context, state) {
              return TechHomeBody(
                  visits: state.visits,
                  loading:
                      state.getVisitsRequestState == RequestState.loading);
            },
          )),
    ));
  }
}
