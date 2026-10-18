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
