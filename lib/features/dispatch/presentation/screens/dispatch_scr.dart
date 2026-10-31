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
    return BlocProvider(
        create: (context) => sl<DispatchBloc>()
          ..add(const GetDispatchBoardEvent(noParameters: NoParameters())),
        child: BlocConsumer<DispatchBloc, DispatchState>(
          listener: (context, state) {
            if (state.bulkAssignRequestState != RequestState.loaded) return;
            final failed = state.bulkFailures.length;
            AppToasts.showMessage(
                '${state.bulkSucceeded} visit${state.bulkSucceeded == 1 ? '' : 's'} '
                'assigned${failed == 0 ? '' : ', $failed could not be assigned'}',
                isError: failed > 0 && state.bulkSucceeded == 0);
          },
          listenWhen: (previous, current) =>
              previous.bulkAssignRequestState != current.bulkAssignRequestState,
          builder: (context, state) => DispatchBody(state: state),
        ));
  }
}
