part of 'tech_bloc.dart';

class TechState extends Equatable {
  final List<TechnicianModel> technicians;
  final TechnicianDetailModel technicianDetailModel;
  final RequestState addTechnicianRequestState;
  final RequestState getTechniciansRequestState;
  final RequestState removeTechnicianRequestState;
  final RequestState getTechnicianDetailRequestState;

  const TechState({
    this.technicians = const [],
    this.technicianDetailModel = const TechnicianDetailModel(),
    this.addTechnicianRequestState = RequestState.loaded,
    this.getTechniciansRequestState = RequestState.loaded,
    this.removeTechnicianRequestState = RequestState.loaded,
    this.getTechnicianDetailRequestState = RequestState.loaded,
  });

  TechState copyWith({
    List<TechnicianModel>? technicians,
    TechnicianDetailModel? technicianDetailModel,
    RequestState? addTechnicianRequestState,
    RequestState? getTechniciansRequestState,
    RequestState? removeTechnicianRequestState,
    RequestState? getTechnicianDetailRequestState,
  }) {
    return TechState(
      technicians: technicians ?? this.technicians,
      technicianDetailModel:
          technicianDetailModel ?? this.technicianDetailModel,
      addTechnicianRequestState:
          addTechnicianRequestState ?? this.addTechnicianRequestState,
      getTechniciansRequestState:
          getTechniciansRequestState ?? this.getTechniciansRequestState,
      removeTechnicianRequestState:
          removeTechnicianRequestState ?? this.removeTechnicianRequestState,
      getTechnicianDetailRequestState: getTechnicianDetailRequestState ??
          this.getTechnicianDetailRequestState,
    );
  }

  @override
  List<Object> get props => [
        technicians,
        technicianDetailModel,
        addTechnicianRequestState,
        getTechniciansRequestState,
        removeTechnicianRequestState,
        getTechnicianDetailRequestState,
      ];
}
