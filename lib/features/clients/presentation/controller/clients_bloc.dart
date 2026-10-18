import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/clients/data/models/client_detail_model/client_detail_model.dart';
import 'package:visit_proof/features/clients/domain/usecases/add_client_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/add_equipment_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/get_client_detail_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/get_clients_uc.dart';

import '../../../../core/utils/enums.dart';
import '../../data/models/client_model.dart';
import '../../domain/usecases/remove_client_uc.dart';
import '../../domain/usecases/remove_equipment_uc.dart';

part 'clients_event.dart';
part 'clients_state.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  final GetClientsUc getClientsUc;
  final AddClientUc addClientUc;
  final GetClientDetailUc getClientDetailUc;
  final RemoveClientUc removeClientUc;
  final AddEquipmentUc addEquipmentUc;
  final RemoveEquipmentUc removeEquipmentUc;
  ClientsBloc(this.addClientUc, this.getClientsUc, this.getClientDetailUc,
      this.removeClientUc, this.addEquipmentUc, this.removeEquipmentUc)
      : super(ClientsState()) {
    on<GetClientsEvent>(_getClients);
    on<AddClientEvent>(_addClient);
    on<GetClientDetailEvent>(_getClientDetail);
    on<RemoveClientEvent>(_removeClient);
    on<AddEquipmentEvent>(_addEquipment);
    on<RemoveEquipmentEvent>(_removeEquipment);
  }

  FutureOr<void> _getClients(
      GetClientsEvent event, Emitter<ClientsState> emit) async {
    emit(state.copyWith(getClientsRequestState: RequestState.loading));
    final result = await getClientsUc.call(event.noParameters);
    result.fold(
        (l) => emit(state.copyWith(getClientsRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getClientsRequestState: RequestState.loaded, clients: r)));
  }

  FutureOr<void> _addClient(
      AddClientEvent event, Emitter<ClientsState> emit) async {
    emit(state.copyWith(addClientRequestState: RequestState.loading));
    final result = await addClientUc.call(event.addClientParameters);
    result.fold(
        (l) => emit(state.copyWith(addClientRequestState: RequestState.error)),
        (r) =>
            emit(state.copyWith(addClientRequestState: RequestState.loaded)));
  }

  FutureOr<void> _getClientDetail(
      GetClientDetailEvent event, Emitter<ClientsState> emit) async {
    emit(state.copyWith(getClientDetailRequestState: RequestState.loading));
    final result =
        await getClientDetailUc.call(event.getClientDetailParameters);
    result.fold(
        (l) => emit(
            state.copyWith(getClientDetailRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getClientDetailRequestState: RequestState.loaded,
            clientDetailModel: r)));
  }

  FutureOr<void> _removeClient(
      RemoveClientEvent event, Emitter<ClientsState> emit) async {
    emit(state.copyWith(removeClientRequestState: RequestState.loading));
    final result = await removeClientUc.call(event.removeClientParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(removeClientRequestState: RequestState.error)),
        (r) => emit(
            state.copyWith(removeClientRequestState: RequestState.loaded)));
  }

  FutureOr<void> _addEquipment(
      AddEquipmentEvent event, Emitter<ClientsState> emit) async {
    emit(state.copyWith(addEquipmentRequestState: RequestState.loading));
    final result = await addEquipmentUc.call(event.addEquipmentParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(addEquipmentRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            addEquipmentRequestState: RequestState.loaded,
            clientDetailModel: r)));
  }

  FutureOr<void> _removeEquipment(
      RemoveEquipmentEvent event, Emitter<ClientsState> emit) async {
    emit(state.copyWith(
        equipmentIDActions: event.removeEquipmentParameters.equipmentID,
        removeEquipmentRequestState: RequestState.loading));
    final result =
        await removeEquipmentUc.call(event.removeEquipmentParameters);
    result.fold(
        (l) => emit(state.copyWith(
            equipmentIDActions: '',
            removeEquipmentRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            equipmentIDActions: '',
            removeEquipmentRequestState: RequestState.loaded,
            clientDetailModel: r)));
  }
}
