part of 'visit_detail_bloc.dart';

class VisitDetailState extends Equatable {
  final VisitDetailModel? visit;
  final List<VisitClientModel> clients;
  final List<ServiceModel> services;
  final List<TechnicianModel> technicians;
  final RequestState getState;
  final RequestState actionState;
  final RequestState optionsState;
  final String? error;
  final int actionSuccessCount;

  const VisitDetailState({this.visit, this.clients = const [], this.services = const [],
    this.technicians = const [], this.getState = RequestState.loaded,
    this.actionState = RequestState.loaded, this.optionsState = RequestState.loaded,
    this.error, this.actionSuccessCount = 0});

  VisitDetailState copyWith({VisitDetailModel? visit, List<VisitClientModel>? clients,
    List<ServiceModel>? services, List<TechnicianModel>? technicians,
    RequestState? getState, RequestState? actionState, RequestState? optionsState,
    String? error, bool clearError = false, int? actionSuccessCount}) => VisitDetailState(
    visit: visit ?? this.visit, clients: clients ?? this.clients,
    services: services ?? this.services, technicians: technicians ?? this.technicians,
    getState: getState ?? this.getState, actionState: actionState ?? this.actionState,
    optionsState: optionsState ?? this.optionsState,
    error: clearError ? null : (error ?? this.error),
    actionSuccessCount: actionSuccessCount ?? this.actionSuccessCount,
  );

  @override List<Object?> get props => [visit, clients, services, technicians,
    getState, actionState, optionsState, error, actionSuccessCount];
}
