import 'package:visit_proof/configs/app_tours.dart';
import 'package:visit_proof/core/utils/general_widgets/g_widget_tour.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/utils/enums.dart';
import 'package:visit_proof/features/clients/domain/usecases/get_client_detail_uc.dart';
import 'package:visit_proof/features/clients/presentation/controller/clients_bloc.dart';
import 'package:visit_proof/features/clients/presentation/widgets/client_detail_widgets/client_detail_body.dart';

import '../../../../core/services/services_locator.dart';

class ClientDetailScr extends StatelessWidget {
  const ClientDetailScr({super.key});
  static const route = '/ClientDetailScr';

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    ClientDetailArgu argu = ClientDetailArgu(clientID: '');
    if (data != null) {
      argu = ClientDetailArgu.fromJson(data);
    }

    return GWidgetTourFlag(tour: AppTours.clientDetail, child: BlocProvider(
        create: (context) => sl<ClientsBloc>()
          ..add(GetClientDetailEvent(
              getClientDetailParameters:
                  GetClientDetailParameters(clientID: argu.clientID))),
        child: BlocConsumer<ClientsBloc, ClientsState>(
          listener: (context, state) {
            if (state.removeClientRequestState == RequestState.loaded) {
              Navigator.pop(context, true);
            }
          },
          listenWhen: (previous, current) =>
              previous.removeClientRequestState !=
              current.removeClientRequestState,
          builder: (context, state) {
            return ClientDetailBody(
                laoding:
                    state.getClientDetailRequestState == RequestState.loading,
                addEquipmentLoading:
                    state.addEquipmentRequestState == RequestState.loading,
                equipmentIDLoading: state.equipmentIDActions,
                removeEquipmentLoading:
                    state.removeEquipmentRequestState == RequestState.loading,
                removeClientLoading:
                    state.removeClientRequestState == RequestState.loading,
                client: state.clientDetailModel);
          },
        )));
  }
}

class ClientDetailArgu {
  final String clientID;
  ClientDetailArgu({required this.clientID});
  Map<String, dynamic> toArgu() => {'clientID': clientID};
  factory ClientDetailArgu.fromJson(Map<String, dynamic> argu) =>
      ClientDetailArgu(clientID: argu['clientID']);
}
