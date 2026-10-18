import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/features/technicians/presentation/controller/tech_bloc.dart';
import 'package:visit_proof/features/technicians/presentation/widgets/technicians_widgets/technicians_body.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums.dart';

class TechniciansScr extends StatelessWidget {
  const TechniciansScr({super.key});
  static const route = '/TechniciansScr';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<TechBloc>()
          ..add(GetTechniciansEvent(noParameters: NoParameters())),
        child: BlocBuilder<TechBloc, TechState>(
          builder: (context, state) {
            return TechniciansBody(
                loading:
                    state.getTechniciansRequestState == RequestState.loading,
                technicians: state.technicians);
          },
        ));
  }
}
