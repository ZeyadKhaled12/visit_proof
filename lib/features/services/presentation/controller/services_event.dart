part of 'services_bloc.dart';

abstract class ServicesEvent extends Equatable {
  const ServicesEvent();

  @override
  List<Object> get props => [];
}

class GetServicesEvent extends ServicesEvent {
  final NoParameters noParameters;
  const GetServicesEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}

class GetCategoriesEvent extends ServicesEvent {
  final NoParameters noParameters;
  const GetCategoriesEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}

class AddServiceEvent extends ServicesEvent {
  final AddServiceParameters addServiceParameters;
  const AddServiceEvent({required this.addServiceParameters});
  @override
  List<Object> get props => [addServiceParameters];
}

class RemoveServiceEvent extends ServicesEvent {
  final RemoveServiceParameters removeServiceParameters;
  const RemoveServiceEvent({required this.removeServiceParameters});
  @override
  List<Object> get props => [removeServiceParameters];
}
