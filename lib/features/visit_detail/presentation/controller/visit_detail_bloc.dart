import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums.dart';
import '../../../invoices/data/models/invoice_detail_model.dart';
import '../../../invoices/domain/usecases/get_invoice_detail_uc.dart';
import '../../../services/data/models/service_model.dart';
import '../../../services/domain/usecases/get_services_uc.dart';
import '../../../technicians/data/models/technician_model.dart';
import '../../../technicians/domain/usecases/get_technicians_uc.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/usecases/add_visit_comment_uc.dart';
import '../../domain/usecases/assign_technician_uc.dart';
import '../../domain/usecases/change_visit_service_uc.dart';
import '../../domain/usecases/change_visit_site_uc.dart';
import '../../domain/usecases/change_visit_status_uc.dart';
import '../../domain/usecases/delete_visit_uc.dart';
import '../../domain/usecases/get_visit_detail_uc.dart';
import '../../domain/usecases/reschedule_visit_uc.dart';
import '../../domain/usecases/unassign_technician_uc.dart';
import '../../domain/usecases/update_visit_info_uc.dart';

part 'visit_detail_event.dart';
part 'visit_detail_state.dart';

typedef _StateWith = VisitDetailState Function(RequestState requestState);

class VisitDetailBloc extends Bloc<VisitDetailEvent, VisitDetailState> {
  final GetVisitDetailUc getVisitDetailUc;
  final ChangeVisitStatusUc changeVisitStatusUc;
  final AssignTechnicianUc assignTechnicianUc;
  final UnassignTechnicianUc unassignTechnicianUc;
  final RescheduleVisitUc rescheduleVisitUc;
  final UpdateVisitInfoUc updateVisitInfoUc;
  final ChangeVisitServiceUc changeVisitServiceUc;
  final ChangeVisitSiteUc changeVisitSiteUc;
  final AddVisitCommentUc addVisitCommentUc;
  final DeleteVisitUc deleteVisitUc;
  final GetTechniciansUc getTechniciansUc;
  final GetServicesUc getServicesUc;
  final GetInvoiceDetailUc getInvoiceDetailUc;

  VisitDetailBloc(
      this.getVisitDetailUc,
      this.changeVisitStatusUc,
      this.assignTechnicianUc,
      this.unassignTechnicianUc,
      this.rescheduleVisitUc,
      this.updateVisitInfoUc,
      this.changeVisitServiceUc,
      this.changeVisitSiteUc,
      this.addVisitCommentUc,
      this.deleteVisitUc,
      this.getTechniciansUc,
      this.getServicesUc,
      this.getInvoiceDetailUc)
      : super(const VisitDetailState()) {
    on<GetVisitDetailEvent>(_getVisitDetail);
    on<GetVisitTechniciansEvent>(_getVisitTechnicians);
    on<GetVisitServicesEvent>(_getVisitServices);
    on<ChangeVisitStatusEvent>(_changeVisitStatus);
    on<AssignTechnicianEvent>(_assignTechnician);
    on<UnassignTechnicianEvent>(_unassignTechnician);
    on<RescheduleVisitEvent>(_rescheduleVisit);
    on<UpdateVisitInfoEvent>(_updateVisitInfo);
    on<ChangeVisitServiceEvent>(_changeVisitService);
    on<ChangeVisitSiteEvent>(_changeVisitSite);
    on<AddVisitCommentEvent>(_addVisitComment);
    on<DeleteVisitEvent>(_deleteVisit);
  }

  // ==========================================================
  // LOAD
  // ==========================================================

  FutureOr<void> _getVisitDetail(
      GetVisitDetailEvent event, Emitter<VisitDetailState> emit) async {
    emit(state.copyWith(getVisitDetailRequestState: RequestState.loading));
    final result = await getVisitDetailUc.call(event.getVisitDetailParameters);
    if (result.isLeft) {
      emit(state.copyWith(getVisitDetailRequestState: RequestState.error));
      return;
    }
    emit(state.copyWith(
        getVisitDetailRequestState: RequestState.loaded, visit: result.right));
    await _loadInvoice(emit);
  }

  /// Same source add_visit uses to list technicians.
  FutureOr<void> _getVisitTechnicians(
      GetVisitTechniciansEvent event, Emitter<VisitDetailState> emit) async {
    emit(state.copyWith(getTechniciansRequestState: RequestState.loading));
    final result = await getTechniciansUc.call(event.noParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(getTechniciansRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getTechniciansRequestState: RequestState.loaded, technicians: r)));
  }

  FutureOr<void> _getVisitServices(
      GetVisitServicesEvent event, Emitter<VisitDetailState> emit) async {
    emit(state.copyWith(getServicesRequestState: RequestState.loading));
    final result = await getServicesUc.call(event.noParameters);
    result.fold(
        (l) => emit(state.copyWith(getServicesRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getServicesRequestState: RequestState.loaded, services: r)));
  }

  /// Loads the linked invoice for the summary card.
  Future<void> _loadInvoice(Emitter<VisitDetailState> emit) async {
    final invoiceID = state.visit.invoiceID;
    if (invoiceID == null || invoiceID.isEmpty) return;

    emit(state.copyWith(getInvoiceRequestState: RequestState.loading));
    final result = await getInvoiceDetailUc
        .call(GetInvoiceDetailParameters(invoiceId: invoiceID));
    result.fold(
        (l) => emit(state.copyWith(getInvoiceRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getInvoiceRequestState: RequestState.loaded, invoice: r)));
  }

  // ==========================================================
  // VISIT ACTIONS
  // ==========================================================

  FutureOr<void> _changeVisitStatus(
          ChangeVisitStatusEvent event, Emitter<VisitDetailState> emit) =>
      _updateVisit(emit,
          call: () => changeVisitStatusUc.call(event.changeVisitStatusParameters),
          stateWith: (s) => state.copyWith(changeStatusRequestState: s));

  FutureOr<void> _assignTechnician(
          AssignTechnicianEvent event, Emitter<VisitDetailState> emit) =>
      _updateVisit(emit,
          call: () => assignTechnicianUc.call(event.assignTechnicianParameters),
          stateWith: (s) => state.copyWith(assignTechnicianRequestState: s));

  FutureOr<void> _unassignTechnician(
          UnassignTechnicianEvent event, Emitter<VisitDetailState> emit) =>
      _updateVisit(emit,
          call: () =>
              unassignTechnicianUc.call(event.unassignTechnicianParameters),
          stateWith: (s) => state.copyWith(unassignTechnicianRequestState: s));

  FutureOr<void> _rescheduleVisit(
          RescheduleVisitEvent event, Emitter<VisitDetailState> emit) =>
      _updateVisit(emit,
          call: () => rescheduleVisitUc.call(event.rescheduleVisitParameters),
          stateWith: (s) => state.copyWith(rescheduleRequestState: s));

  FutureOr<void> _updateVisitInfo(
          UpdateVisitInfoEvent event, Emitter<VisitDetailState> emit) =>
      _updateVisit(emit,
          call: () => updateVisitInfoUc.call(event.updateVisitInfoParameters),
          stateWith: (s) => state.copyWith(updateInfoRequestState: s));

  FutureOr<void> _changeVisitService(
          ChangeVisitServiceEvent event, Emitter<VisitDetailState> emit) =>
      _updateVisit(emit,
          call: () =>
              changeVisitServiceUc.call(event.changeVisitServiceParameters),
          stateWith: (s) => state.copyWith(changeServiceRequestState: s));

  FutureOr<void> _changeVisitSite(
          ChangeVisitSiteEvent event, Emitter<VisitDetailState> emit) =>
      _updateVisit(emit,
          call: () => changeVisitSiteUc.call(event.changeVisitSiteParameters),
          stateWith: (s) => state.copyWith(changeSiteRequestState: s));

  FutureOr<void> _addVisitComment(
          AddVisitCommentEvent event, Emitter<VisitDetailState> emit) =>
      _updateVisit(emit,
          call: () => addVisitCommentUc.call(event.addVisitCommentParameters),
          stateWith: (s) => state.copyWith(addCommentRequestState: s));

  FutureOr<void> _deleteVisit(
      DeleteVisitEvent event, Emitter<VisitDetailState> emit) async {
    emit(state.copyWith(deleteVisitRequestState: RequestState.loading));
    final result = await deleteVisitUc.call(event.deleteVisitParameters);
    result.fold(
        (l) => emit(state.copyWith(deleteVisitRequestState: RequestState.error)),
        (r) =>
            emit(state.copyWith(deleteVisitRequestState: RequestState.loaded)));
  }

  /// Visit edits can touch the invoice (cancel, reprice, site), so the
  /// invoice summary is reloaded after every successful change.
  Future<void> _updateVisit(
    Emitter<VisitDetailState> emit, {
    required Future<Either<Failure, VisitDetailModel>> Function() call,
    required _StateWith stateWith,
  }) async {
    emit(stateWith(RequestState.loading));
    final result = await call();
    if (result.isLeft) {
      emit(stateWith(RequestState.error));
      return;
    }
    emit(stateWith(RequestState.loaded).copyWith(visit: result.right));
    await _loadInvoice(emit);
  }
}
