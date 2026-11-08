import 'package:visit_proof/configs/app_tours.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_tech_detail_uc.dart';
import 'package:visit_proof/features/technicians/presentation/controller/tech_bloc.dart';
import 'package:visit_proof/features/technicians/presentation/widgets/technician_detail_widgets/technician_detail_body.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/utils/enums.dart';

class TechnicianDetailScr extends StatelessWidget {
  const TechnicianDetailScr({super.key});
  static const route = '/TechnicianDetailScr';

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    TechnicianDetailArgu argu = TechnicianDetailArgu(techID: '');
    if (data != null) {
      argu = TechnicianDetailArgu.fromJson(data);
    }

    return GWidgetTourFlag(tour: AppTours.technicianDetail, child: BlocProvider(
        create: (context) => sl<TechBloc>()
          ..add(GetTechDetailEvent(
              getTechDetailParameters:
                  GetTechDetailParameters(techID: argu.techID))),
        child: BlocConsumer<TechBloc, TechState>(
          listener: (context, state) {
            if (state.removeTechnicianRequestState == RequestState.loaded) {
              Navigator.pop(context, true);
            }
          },
          listenWhen: (previous, current) =>
              previous.removeTechnicianRequestState !=
              current.removeTechnicianRequestState,
          builder: (context, state) {
            return TechnicianDetailBody(
                loading: state.getTechnicianDetailRequestState ==
                    RequestState.loading,
                removeClientLoading:
                    state.removeTechnicianRequestState == RequestState.loading,
                technicianDetailModel: state.technicianDetailModel);
          },
        )));
  }
}

class TechnicianDetailArgu {
  final String techID;
  TechnicianDetailArgu({required this.techID});
  Map<String, dynamic> toArgu() => {'techID': techID};
  factory TechnicianDetailArgu.fromJson(Map<String, dynamic> argu) =>
      TechnicianDetailArgu(techID: argu['techID']);
}
