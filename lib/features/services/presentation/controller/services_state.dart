part of 'services_bloc.dart';

class ServicesState extends Equatable {
  final List<ServiceModel> services;
  final List<GModelCatg> categories;
  final RequestState getServicesRequestState;
  final RequestState addServiceRequestState;
  final RequestState getCategoriesRequestState;

  const ServicesState({
    this.services = const [],
    this.categories = const [],
    this.getServicesRequestState = RequestState.loaded,
    this.addServiceRequestState = RequestState.loaded,
    this.getCategoriesRequestState = RequestState.loaded,
  });

  ServicesState copyWith(
      {List<ServiceModel>? services,
      List<GModelCatg>? categories,
      RequestState? getServicesRequestState,
      RequestState? addServiceRequestState,
      RequestState? getCategoriesRequestState}) {
    return ServicesState(
      services: services ?? this.services,
      categories: categories ?? this.categories,
      getServicesRequestState:
          getServicesRequestState ?? this.getServicesRequestState,
      addServiceRequestState:
          addServiceRequestState ?? this.addServiceRequestState,
      getCategoriesRequestState:
          getCategoriesRequestState ?? this.getCategoriesRequestState,
    );
  }

  @override
  List<Object> get props => [
        services,
        categories,
        getServicesRequestState,
        addServiceRequestState,
        getCategoriesRequestState
      ];
}
