import 'package:visit_proof/configs/app_tours.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/enums.dart';
import 'package:visit_proof/features/visits/presentation/controller/visits_bloc.dart';
import 'package:visit_proof/features/visits/presentation/widgets/visits_body.dart';

import '../../../../core/services/services_locator.dart';

class VisitsScr extends StatelessWidget {
  const VisitsScr({super.key});

  @override
  Widget build(BuildContext context) {
    return GWidgetTourFlag(tour: AppTours.visits, child: BlocProvider(
        create: (context) =>
            sl<VisitsBloc>()..add(GetVisitsEvent(noParameters: NoParameters())),
        child: BlocBuilder<VisitsBloc, VisitsState>(
          builder: (context, state) {
            return VisitsBody(
                visits: state.visits,
                loading: state.getVisitsRequestState == RequestState.loading);
          },
        )));
  }
}
