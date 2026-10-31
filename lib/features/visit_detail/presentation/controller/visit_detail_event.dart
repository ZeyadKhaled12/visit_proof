part of 'visit_detail_bloc.dart';

abstract class VisitDetailEvent extends Equatable {
  const VisitDetailEvent();
  @override List<Object?> get props => [];
}
class LoadVisitDetailEvent extends VisitDetailEvent {
  final String visitID;
  const LoadVisitDetailEvent(this.visitID);
  @override List<Object?> get props => [visitID];
}
class LoadVisitEditOptionsEvent extends VisitDetailEvent {
  const LoadVisitEditOptionsEvent();
}
class UpdateVisitEvent extends VisitDetailEvent {
  final UpdateVisitParameters parameters;
  const UpdateVisitEvent(this.parameters);
  @override List<Object?> get props => [parameters];
}
class ChangeVisitStatusEvent extends VisitDetailEvent {
  final ChangeVisitStatusParameters parameters;
  const ChangeVisitStatusEvent(this.parameters);
  @override List<Object?> get props => [parameters];
}
class AssignVisitTechnicianEvent extends VisitDetailEvent {
  final AssignVisitTechnicianParameters parameters;
  const AssignVisitTechnicianEvent(this.parameters);
  @override List<Object?> get props => [parameters];
}
class UnassignVisitTechnicianEvent extends VisitDetailEvent {
  final UnassignVisitTechnicianParameters parameters;
  const UnassignVisitTechnicianEvent(this.parameters);
  @override List<Object?> get props => [parameters];
}
class AddVisitCommentEvent extends VisitDetailEvent {
  final AddVisitCommentParameters parameters;
  const AddVisitCommentEvent(this.parameters);
  @override List<Object?> get props => [parameters];
}
