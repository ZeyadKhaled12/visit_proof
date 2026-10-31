part of 'dispatch_bloc.dart';

abstract class DispatchEvent extends Equatable {
  const DispatchEvent();

  @override
  List<Object> get props => [];
}

class GetDispatchBoardEvent extends DispatchEvent {
  final NoParameters noParameters;
  const GetDispatchBoardEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}

class ChangeDispatchDateEvent extends DispatchEvent {
  final DateTime date;
  const ChangeDispatchDateEvent({required this.date});
  @override
  List<Object> get props => [date];
}

class DispatchAssignEvent extends DispatchEvent {
  final AssignTechnicianParameters assignTechnicianParameters;
  const DispatchAssignEvent({required this.assignTechnicianParameters});
  @override
  List<Object> get props => [assignTechnicianParameters];
}

class DispatchBulkAssignEvent extends DispatchEvent {
  final List<AssignTechnicianParameters> assignments;
  const DispatchBulkAssignEvent({required this.assignments});
  @override
  List<Object> get props => [assignments];
}

class DispatchUnassignEvent extends DispatchEvent {
  final UnassignTechnicianParameters unassignTechnicianParameters;
  const DispatchUnassignEvent({required this.unassignTechnicianParameters});
  @override
  List<Object> get props => [unassignTechnicianParameters];
}

class DispatchRescheduleEvent extends DispatchEvent {
  final RescheduleVisitParameters rescheduleVisitParameters;
  const DispatchRescheduleEvent({required this.rescheduleVisitParameters});
  @override
  List<Object> get props => [rescheduleVisitParameters];
}

class DispatchChangeStatusEvent extends DispatchEvent {
  final ChangeVisitStatusParameters changeVisitStatusParameters;
  const DispatchChangeStatusEvent({required this.changeVisitStatusParameters});
  @override
  List<Object> get props => [changeVisitStatusParameters];
}

class DispatchChangePriorityEvent extends DispatchEvent {
  final UpdateVisitInfoParameters updateVisitInfoParameters;
  const DispatchChangePriorityEvent({required this.updateVisitInfoParameters});
  @override
  List<Object> get props => [updateVisitInfoParameters];
}

class SaveDispatchSettingsEvent extends DispatchEvent {
  final SaveDispatchSettingsParameters saveDispatchSettingsParameters;
  const SaveDispatchSettingsEvent(
      {required this.saveDispatchSettingsParameters});
  @override
  List<Object> get props => [saveDispatchSettingsParameters];
}

class SetTechnicianDayOffEvent extends DispatchEvent {
  final SetTechnicianDayOffParameters setTechnicianDayOffParameters;
  const SetTechnicianDayOffEvent(
      {required this.setTechnicianDayOffParameters});
  @override
  List<Object> get props => [setTechnicianDayOffParameters];
}
