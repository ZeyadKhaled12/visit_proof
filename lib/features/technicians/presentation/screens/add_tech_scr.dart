import 'package:visit_proof/configs/app_tours.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/technicians/data/models/technician_detail_model.dart';
import 'package:visit_proof/features/technicians/presentation/controller/tech_bloc.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/utils/enums.dart';
import '../widgets/add_technician_widgets/add_tech_body.dart';

// --- SCREEN IMPLEMENTATION ---

//name length from 2 to 100
//phone format
//email format
//Password format
//categories can't be empty

class AddTechScr extends StatelessWidget {
  const AddTechScr({super.key});
  static const route = '/AddTechScr';

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    AddTechArgu argu = AddTechArgu();
    if (data != null) {
      argu = AddTechArgu.fromJson(data);
    }

    return GWidgetTourFlag(tour: AppTours.addTechnician, child: BlocProvider(
        create: (context) => sl<TechBloc>()
          ..add(GetTCategoriesEvent(noParameters: NoParameters())),
        child: BlocConsumer<TechBloc, TechState>(
          listener: (context, state) {
            if (state.addTechnicianRequestState == RequestState.loaded) {
              Navigator.pop(context, state.technicianDetailModel);
            }
          },
          listenWhen: (previous, current) =>
              previous.addTechnicianRequestState !=
              current.addTechnicianRequestState,
          builder: (context, state) {
            return AddTechBody(
                technicianDetailModel: argu.technicianDetailModel,
                categories: state.categories,
                categoriesLoading:
                    state.getCategoriesRequestState == RequestState.loading,
                loading:
                    state.addTechnicianRequestState == RequestState.loading);
          },
        )));
  }
}

class AddTechArgu {
  final TechnicianDetailModel? technicianDetailModel;
  AddTechArgu({this.technicianDetailModel});
  Map<String, dynamic> toArgu() =>
      {'technicianDetailModel': technicianDetailModel};
  factory AddTechArgu.fromJson(Map<String, dynamic> argu) =>
      AddTechArgu(technicianDetailModel: argu['technicianDetailModel']);
}
