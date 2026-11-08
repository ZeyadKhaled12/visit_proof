import 'package:visit_proof/configs/app_tours.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:visit_proof/configs/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../configs/app_toasts.dart';
import '../../../../core/services/services_locator.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums.dart';
import '../controller/dispatch_bloc.dart';
import '../widgets/dispatch_body.dart';

class DispatchScr extends StatelessWidget {
  const DispatchScr({super.key});
  static const route = '/DispatchScr';

  @override
  Widget build(BuildContext context) {
    return GWidgetTourFlag(tour: AppTours.dispatch, child: BlocProvider(
        create: (context) => sl<DispatchBloc>()
          ..add(const GetDispatchBoardEvent(noParameters: NoParameters())),
        child: BlocConsumer<DispatchBloc, DispatchState>(
          listener: (context, state) {
            if (state.bulkAssignRequestState != RequestState.loaded) return;
            final failed = state.bulkFailures.length;
            AppToasts.showMessage(
                failed == 0
                    ? 'Visits assigned: {0}'.trArgs([state.bulkSucceeded])
                    : 'Visits assigned: {0}, not assigned: {1}'
                        .trArgs([state.bulkSucceeded, failed]),
                isError: failed > 0 && state.bulkSucceeded == 0);
          },
          listenWhen: (previous, current) =>
              previous.bulkAssignRequestState != current.bulkAssignRequestState,
          builder: (context, state) => DispatchBody(state: state),
        )));
  }
}
