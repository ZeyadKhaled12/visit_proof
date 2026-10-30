part of 'add_visit_bloc.dart';

class AddVisitState extends Equatable {
  final List<VisitClientModel> clients;
  final List<ServiceModel> services;
  final List<TechnicianModel> technicans;
  final RequestState getClientsRequestState;
  final RequestState getServicesRequestState;
  final RequestState getTechnicanRequestState;
  final RequestState addVisitRequestState;

  const AddVisitState({
    this.clients = const [],
    this.services = const [],
    this.technicans = const [],
    this.getClientsRequestState = RequestState.loaded,
    this.getServicesRequestState = RequestState.loaded,
    this.getTechnicanRequestState = RequestState.loaded,
    this.addVisitRequestState = RequestState.loaded,
  });

  AddVisitState copyWith(
      {List<VisitClientModel>? clients,
      List<ServiceModel>? services,
      List<TechnicianModel>? technicans,
      RequestState? getClientsRequestState,
      RequestState? getServicesRequestState,
      RequestState? getTechnicanRequestState,
      RequestState? addVisitRequestState}) {
    return AddVisitState(
      clients: clients ?? this.clients,
      services: services ?? this.services,
      technicans: technicans ?? this.technicans,
      getClientsRequestState:
          getClientsRequestState ?? this.getClientsRequestState,
      getServicesRequestState:
          getServicesRequestState ?? this.getServicesRequestState,
      getTechnicanRequestState:
          getTechnicanRequestState ?? this.getTechnicanRequestState,
      addVisitRequestState: addVisitRequestState ?? this.addVisitRequestState,
    );
  }

  @override
  List<Object> get props => [
        clients,
        services,
        technicans,
        getClientsRequestState,
        getServicesRequestState,
        getTechnicanRequestState,
        addVisitRequestState
      ];
}
