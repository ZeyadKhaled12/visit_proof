part of 'clients_bloc.dart';

abstract class ClientsEvent extends Equatable {
  const ClientsEvent();

  @override
  List<Object> get props => [];
}

class GetClientsEvent extends ClientsEvent {
  final NoParameters noParameters;
  const GetClientsEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}

class AddClientEvent extends ClientsEvent {
  final AddClientParameters addClientParameters;
  const AddClientEvent({required this.addClientParameters});
  @override
  List<Object> get props => [addClientParameters];
}

class GetClientDetailEvent extends ClientsEvent {
  final GetClientDetailParameters getClientDetailParameters;
  const GetClientDetailEvent({required this.getClientDetailParameters});
  @override
  List<Object> get props => [getClientDetailParameters];
}

class RemoveClientEvent extends ClientsEvent {
  final RemoveClientParameters removeClientParameters;
  const RemoveClientEvent({required this.removeClientParameters});
  @override
  List<Object> get props => [removeClientParameters];
}

class AddEquipmentEvent extends ClientsEvent {
  final AddEquipmentParameters addEquipmentParameters;
  const AddEquipmentEvent({required this.addEquipmentParameters});
  @override
  List<Object> get props => [addEquipmentParameters];
}

class RemoveEquipmentEvent extends ClientsEvent {
  final RemoveEquipmentParameters removeEquipmentParameters;
  const RemoveEquipmentEvent({required this.removeEquipmentParameters});
  @override
  List<Object> get props => [removeEquipmentParameters];
}
