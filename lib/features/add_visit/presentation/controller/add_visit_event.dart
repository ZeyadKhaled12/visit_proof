part of 'add_visit_bloc.dart';

abstract class AddVisitEvent extends Equatable {
  const AddVisitEvent();

  @override
  List<Object> get props => [];
}

class GetVisitClientsEvent extends AddVisitEvent {
  final NoParameters noParameters;
  const GetVisitClientsEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}

class GetVisitServicesEvent extends AddVisitEvent {
  final NoParameters noParameters;
  const GetVisitServicesEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}

class GetVisitTechnicainsEvent extends AddVisitEvent {
  final NoParameters noParameters;
  const GetVisitTechnicainsEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}

class AddNewVisitEvent extends AddVisitEvent {
  final AddVisitParameters addVisitParameters;
  const AddNewVisitEvent({required this.addVisitParameters});
  @override
  List<Object> get props => [addVisitParameters];
}
