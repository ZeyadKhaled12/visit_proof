import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/enums.dart';
import 'package:visit_proof/features/clients/presentation/controller/clients_bloc.dart';
import 'package:visit_proof/features/clients/presentation/widgets/clients_widgets/clients_body.dart';

import '../../../../core/services/services_locator.dart';

class ClientsScr extends StatelessWidget {
  const ClientsScr({super.key});
  static const route = '/ClientsScr';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<ClientsBloc>()
          ..add(GetClientsEvent(noParameters: NoParameters())),
        child: BlocBuilder<ClientsBloc, ClientsState>(
          builder: (context, state) {
            return ClientsBody(
                loading: state.getClientsRequestState == RequestState.loading,
                clients: state.clients);
          },
        ));
  }
}
