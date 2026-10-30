part of 'visits_bloc.dart';

abstract class VisitsEvent extends Equatable {
  const VisitsEvent();

  @override
  List<Object> get props => [];
}

class GetVisitsEvent extends VisitsEvent {
  final NoParameters noParameters;
  const GetVisitsEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}
