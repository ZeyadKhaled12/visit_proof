part of 'tech_bloc.dart';

class TechState extends Equatable {
  final List<TechnicianModel> technicians;
  final List<GModelCatg> categories;
  final TechnicianDetailModel technicianDetailModel;
  final RequestState addTechnicianRequestState;
  final RequestState getTechniciansRequestState;
  final RequestState removeTechnicianRequestState;
  final RequestState getTechnicianDetailRequestState;
  final RequestState getCategoriesRequestState;

  const TechState({
    this.technicians = const [],
    this.categories = const [],
    this.technicianDetailModel = const TechnicianDetailModel(),
    this.addTechnicianRequestState = RequestState.loaded,
    this.getTechniciansRequestState = RequestState.loaded,
    this.removeTechnicianRequestState = RequestState.loaded,
    this.getTechnicianDetailRequestState = RequestState.loaded,
    this.getCategoriesRequestState = RequestState.loaded,
  });

  TechState copyWith({
    List<TechnicianModel>? technicians,
    List<GModelCatg>? categories,
    TechnicianDetailModel? technicianDetailModel,
    RequestState? addTechnicianRequestState,
    RequestState? getTechniciansRequestState,
    RequestState? removeTechnicianRequestState,
    RequestState? getTechnicianDetailRequestState,
    RequestState? getCategoriesRequestState,
  }) {
    return TechState(
      technicians: technicians ?? this.technicians,
      categories: categories ?? this.categories,
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
      getCategoriesRequestState:
          getCategoriesRequestState ?? this.getCategoriesRequestState,
    );
  }

  @override
  List<Object> get props => [
        technicians,
        categories,
        technicianDetailModel,
        addTechnicianRequestState,
        getTechniciansRequestState,
        removeTechnicianRequestState,
        getTechnicianDetailRequestState,
        getCategoriesRequestState
      ];
}
