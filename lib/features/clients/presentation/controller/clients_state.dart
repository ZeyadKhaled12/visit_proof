part of 'clients_bloc.dart';

class ClientsState extends Equatable {
  final List<ClientModel> clients;
  final ClientDetailModel clientDetailModel;
  final String equipmentIDActions;
  final RequestState addClientRequestState;
  final RequestState getClientsRequestState;
  final RequestState removeClientRequestState;
  final RequestState addEquipmentRequestState;
  final RequestState removeEquipmentRequestState;
  final RequestState getClientDetailRequestState;

  const ClientsState(
      {this.clients = const [],
      this.clientDetailModel = const ClientDetailModel(),
      this.equipmentIDActions = '',
      this.addClientRequestState = RequestState.loaded,
      this.getClientsRequestState = RequestState.loaded,
      this.removeClientRequestState = RequestState.loaded,
      this.addEquipmentRequestState = RequestState.loaded,
      this.removeEquipmentRequestState = RequestState.loaded,
      this.getClientDetailRequestState = RequestState.loaded});

  ClientsState copyWith(
      {List<ClientModel>? clients,
      ClientDetailModel? clientDetailModel,
      String? equipmentIDActions,
      RequestState? addClientRequestState,
      RequestState? getClientsRequestState,
      RequestState? removeClientRequestState,
      RequestState? addEquipmentRequestState,
      RequestState? removeEquipmentRequestState,
      RequestState? getClientDetailRequestState}) {
    return ClientsState(
        clients: clients ?? this.clients,
        clientDetailModel: clientDetailModel ?? this.clientDetailModel,
        equipmentIDActions: equipmentIDActions ?? this.equipmentIDActions,
        addClientRequestState:
            addClientRequestState ?? this.addClientRequestState,
        getClientsRequestState:
            getClientsRequestState ?? this.getClientsRequestState,
        removeClientRequestState:
            removeClientRequestState ?? this.removeClientRequestState,
        addEquipmentRequestState:
            addEquipmentRequestState ?? this.addEquipmentRequestState,
        removeEquipmentRequestState:
            removeEquipmentRequestState ?? this.removeEquipmentRequestState,
        getClientDetailRequestState:
            getClientDetailRequestState ?? this.getClientDetailRequestState);
  }

  @override
  List<Object> get props => [
        clients,
        clientDetailModel,
        equipmentIDActions,
        addClientRequestState,
        getClientsRequestState,
        removeClientRequestState,
        addEquipmentRequestState,
        removeEquipmentRequestState,
        getClientDetailRequestState
      ];
}
