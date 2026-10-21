part of 'tech_bloc.dart';

abstract class TechEvent extends Equatable {
  const TechEvent();

  @override
  List<Object> get props => [];
}

class GetTechniciansEvent extends TechEvent {
  final NoParameters noParameters;
  const GetTechniciansEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}

class AddTechEvent extends TechEvent {
  final AddTechParameters addTechParameters;
  const AddTechEvent({required this.addTechParameters});
  @override
  List<Object> get props => [addTechParameters];
}

class GetTechDetailEvent extends TechEvent {
  final GetTechDetailParameters getTechDetailParameters;
  const GetTechDetailEvent({required this.getTechDetailParameters});
  @override
  List<Object> get props => [getTechDetailParameters];
}

class RemoveTechEvent extends TechEvent {
  final RemoveTechnicianParameters removeTechnicianParameters;
  const RemoveTechEvent({required this.removeTechnicianParameters});
  @override
  List<Object> get props => [removeTechnicianParameters];
}

class GetTCategoriesEvent extends TechEvent {
  final NoParameters noParameters;
  const GetTCategoriesEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}
