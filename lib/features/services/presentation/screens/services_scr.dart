import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/features/services/presentation/controller/services_bloc.dart';
import 'package:visit_proof/features/services/presentation/widgets/services_widgets/services_body.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums.dart';

class ServicesScr extends StatelessWidget {
  const ServicesScr({super.key});
  static const route = '/ServicesScr';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<ServicesBloc>()
          ..add(GetServicesEvent(noParameters: NoParameters())),
        child: BlocBuilder<ServicesBloc, ServicesState>(
          builder: (context, state) {
            return ServicesBody(
                loading: state.getServicesRequestState == RequestState.loading,
                services: state.services);
          },
        ));
  }
}
