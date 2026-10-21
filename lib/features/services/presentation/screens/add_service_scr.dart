import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/services/data/models/service_model.dart';
import 'package:visit_proof/features/services/presentation/controller/services_bloc.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/utils/enums.dart';
import '../widgets/add_service_widgets/add_service_body.dart';

class AddServiceScr extends StatelessWidget {
  const AddServiceScr({super.key, this.serviceModel});
  final ServiceModel? serviceModel;

  static Future<dynamic> show(BuildContext context,
      {ServiceModel? serviceModel}) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddServiceScr(serviceModel: serviceModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<ServicesBloc>()
          ..add(GetCategoriesEvent(noParameters: NoParameters())),
        child: BlocConsumer<ServicesBloc, ServicesState>(
          listener: (context, state) {
            if (state.addServiceRequestState == RequestState.loaded) {
              Navigator.pop(context, true);
            }
          },
          listenWhen: (previous, current) =>
              previous.addServiceRequestState != current.addServiceRequestState,
          builder: (context, state) {
            return AddServiceBody(
                serviceModel: serviceModel,
                categories: state.categories,
                getCategoriesLoading:
                    state.getCategoriesRequestState == RequestState.loading,
                loading: state.addServiceRequestState == RequestState.loading);
          },
        ));
  }
}
