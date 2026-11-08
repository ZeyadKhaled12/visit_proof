import 'package:visit_proof/configs/app_tours.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/services_locator.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums.dart';
import '../controller/tech_bloc.dart';
import '../widgets/technicians_widgets/technicians_body.dart';

class TechniciansScr extends StatelessWidget {
  const TechniciansScr({super.key});
  static const route = '/TechniciansScr';

  @override
  Widget build(BuildContext context) {
    return GWidgetTourFlag(tour: AppTours.technicians, child: BlocProvider(
        create: (context) => sl<TechBloc>()
          ..add(GetTechniciansEvent(noParameters: NoParameters())),
        child: BlocBuilder<TechBloc, TechState>(
          builder: (context, state) {
            return TechniciansBody(
                loading:
                    state.getTechniciansRequestState == RequestState.loading,
                technicians: state.technicians);
          },
        )));
  }
}
