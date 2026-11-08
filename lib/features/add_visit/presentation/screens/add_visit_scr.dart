import 'package:visit_proof/configs/app_tours.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/enums.dart';
import 'package:visit_proof/features/add_visit/presentation/controller/add_visit_bloc.dart';
import 'package:visit_proof/features/add_visit/presentation/widgets/add_visit_body.dart';

import '../../../../core/services/services_locator.dart';

class AddVisitScr extends StatelessWidget {
  const AddVisitScr({super.key});
  static const route = '/AddVisitScr';

  @override
  Widget build(BuildContext context) {
    return GWidgetTourFlag(tour: AppTours.addVisit, child: BlocProvider(
        create: (context) => sl<AddVisitBloc>()
          ..add(GetVisitClientsEvent(noParameters: NoParameters()))
          ..add(GetVisitServicesEvent(noParameters: NoParameters()))
          ..add(GetVisitTechnicainsEvent(noParameters: NoParameters())),
        child: BlocConsumer<AddVisitBloc, AddVisitState>(
          listener: (context, state) {
            if (state.addVisitRequestState == RequestState.loaded) {
              Navigator.pop(context, true);
            }
          },
          listenWhen: (previous, current) =>
              previous.addVisitRequestState != current.addVisitRequestState,
          builder: (context, state) {
            return AddVisitBody(
              clients: state.clients,
              services: state.services,
              technicians: state.technicans,
              clientsLoading:
                  state.getClientsRequestState == RequestState.loading,
              servicesLoading:
                  state.getServicesRequestState == RequestState.loading,
              technicansLoading:
                  state.getTechnicanRequestState == RequestState.loading,
              addVisitLoading:
                  state.addVisitRequestState == RequestState.loading,
            );
          },
        )));
  }
}
