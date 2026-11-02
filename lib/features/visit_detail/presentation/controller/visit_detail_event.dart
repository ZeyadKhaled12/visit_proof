part of 'visit_detail_bloc.dart';

abstract class VisitDetailEvent extends Equatable {
  const VisitDetailEvent();

  @override
  List<Object> get props => [];
}

class GetVisitDetailEvent extends VisitDetailEvent {
  final GetVisitDetailParameters getVisitDetailParameters;
  const GetVisitDetailEvent({required this.getVisitDetailParameters});
  @override
  List<Object> get props => [getVisitDetailParameters];
}

class GetVisitTechniciansEvent extends VisitDetailEvent {
  final NoParameters noParameters;
  const GetVisitTechniciansEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}

class GetVisitServicesEvent extends VisitDetailEvent {
  final NoParameters noParameters;
  const GetVisitServicesEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}

class ChangeVisitStatusEvent extends VisitDetailEvent {
  final ChangeVisitStatusParameters changeVisitStatusParameters;
  const ChangeVisitStatusEvent({required this.changeVisitStatusParameters});
  @override
  List<Object> get props => [changeVisitStatusParameters];
}

class AssignTechnicianEvent extends VisitDetailEvent {
  final AssignTechnicianParameters assignTechnicianParameters;
  const AssignTechnicianEvent({required this.assignTechnicianParameters});
  @override
  List<Object> get props => [assignTechnicianParameters];
}

class UnassignTechnicianEvent extends VisitDetailEvent {
  final UnassignTechnicianParameters unassignTechnicianParameters;
  const UnassignTechnicianEvent({required this.unassignTechnicianParameters});
  @override
  List<Object> get props => [unassignTechnicianParameters];
}

class RescheduleVisitEvent extends VisitDetailEvent {
  final RescheduleVisitParameters rescheduleVisitParameters;
  const RescheduleVisitEvent({required this.rescheduleVisitParameters});
  @override
  List<Object> get props => [rescheduleVisitParameters];
}

class UpdateVisitInfoEvent extends VisitDetailEvent {
  final UpdateVisitInfoParameters updateVisitInfoParameters;
  const UpdateVisitInfoEvent({required this.updateVisitInfoParameters});
  @override
  List<Object> get props => [updateVisitInfoParameters];
}

class ChangeVisitServiceEvent extends VisitDetailEvent {
  final ChangeVisitServiceParameters changeVisitServiceParameters;
  const ChangeVisitServiceEvent({required this.changeVisitServiceParameters});
  @override
  List<Object> get props => [changeVisitServiceParameters];
}

class ChangeVisitSiteEvent extends VisitDetailEvent {
  final ChangeVisitSiteParameters changeVisitSiteParameters;
  const ChangeVisitSiteEvent({required this.changeVisitSiteParameters});
  @override
  List<Object> get props => [changeVisitSiteParameters];
}

class AddVisitCommentEvent extends VisitDetailEvent {
  final AddVisitCommentParameters addVisitCommentParameters;
  const AddVisitCommentEvent({required this.addVisitCommentParameters});
  @override
  List<Object> get props => [addVisitCommentParameters];
}

class DeleteVisitEvent extends VisitDetailEvent {
  final DeleteVisitParameters deleteVisitParameters;
  const DeleteVisitEvent({required this.deleteVisitParameters});
  @override
  List<Object> get props => [deleteVisitParameters];
}

class CollectPaymentEvent extends VisitDetailEvent {
  final RecordPaymentParameters recordPaymentParameters;
  const CollectPaymentEvent({required this.recordPaymentParameters});
  @override
  List<Object> get props => [recordPaymentParameters];
}
