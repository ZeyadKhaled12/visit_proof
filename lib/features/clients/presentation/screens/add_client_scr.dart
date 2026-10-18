import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/features/clients/data/models/client_detail_model/client_detail_model.dart';
import 'package:visit_proof/features/clients/presentation/controller/clients_bloc.dart';
import 'package:visit_proof/features/clients/presentation/widgets/add_client_widgets/add_client_body.dart';

import '../../../../core/services/services_locator.dart';
import '../../../../core/utils/enums.dart';

class AddClientScr extends StatelessWidget {
  const AddClientScr({super.key});
  static const route = '/AddClientScr';

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    AddClientArgu argu = AddClientArgu();
    if (data != null) {
      argu = AddClientArgu.fromJson(data);
    }

    return BlocProvider(
        create: (context) => sl<ClientsBloc>(),
        child: BlocConsumer<ClientsBloc, ClientsState>(
          listener: (context, state) {
            if (state.addClientRequestState == RequestState.loaded) {
              Navigator.pop(context, true);
            }
          },
          listenWhen: (previous, current) =>
              previous.addClientRequestState != current.addClientRequestState,
          builder: (context, state) {
            return AddClientBody(
                clientDetailModel: argu.client,
                loading: state.addClientRequestState == RequestState.loading);
          },
        ));
  }
}

class AddClientArgu {
  final ClientDetailModel? client;
  AddClientArgu({this.client});
  Map<String, dynamic> toArgu() => {'client': client};
  factory AddClientArgu.fromJson(Map<String, dynamic> argu) =>
      AddClientArgu(client: argu['client']);
}
