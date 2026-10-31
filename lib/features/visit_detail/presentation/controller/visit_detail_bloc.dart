import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/enums.dart';
import 'package:visit_proof/features/clients/domain/usecases/get_clients_uc.dart';
import 'package:visit_proof/features/services/domain/usecases/get_services_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_technicians_uc.dart';
import 'package:visit_proof/features/services/data/models/service_model.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_client_model.dart';
import 'package:visit_proof/features/visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../domain/usecases/visit_detail_actions_uc.dart';

part 'visit_detail_event.dart';
part 'visit_detail_state.dart';

class VisitDetailBloc extends Bloc<VisitDetailEvent, VisitDetailState> {
  final GetVisitDetailUc getVisitDetailUc;
  final UpdateVisitUc updateVisitUc;
  final ChangeVisitStatusUc changeVisitStatusUc;
  final AssignVisitTechnicianUc assignTechnicianUc;
  final UnassignVisitTechnicianUc unassignTechnicianUc;
  final AddVisitCommentUc addVisitCommentUc;
  final GetClientsUc getClientsUc;
  final GetServicesUc getServicesUc;
  final GetTechniciansUc getTechniciansUc;

  VisitDetailBloc(this.getVisitDetailUc, this.updateVisitUc, this.changeVisitStatusUc,
      this.assignTechnicianUc, this.unassignTechnicianUc, this.addVisitCommentUc,
      this.getClientsUc, this.getServicesUc, this.getTechniciansUc)
      : super(const VisitDetailState()) {
    on<LoadVisitDetailEvent>(_load);
    on<LoadVisitEditOptionsEvent>(_options);
    on<UpdateVisitEvent>((e, emit) => _run(emit, () => updateVisitUc.call(e.parameters)));
    on<ChangeVisitStatusEvent>((e, emit) => _run(emit, () => changeVisitStatusUc.call(e.parameters)));
    on<AssignVisitTechnicianEvent>((e, emit) => _run(emit, () => assignTechnicianUc.call(e.parameters)));
    on<UnassignVisitTechnicianEvent>((e, emit) => _run(emit, () => unassignTechnicianUc.call(e.parameters)));
    on<AddVisitCommentEvent>((e, emit) => _run(emit, () => addVisitCommentUc.call(e.parameters)));
  }

  Future<void> _load(LoadVisitDetailEvent event, Emitter<VisitDetailState> emit) async {
    emit(state.copyWith(getState: RequestState.loading, clearError: true));
    final result = await getVisitDetailUc.call(GetVisitDetailParameters(visitID: event.visitID));
    result.fold(
      (failure) => emit(state.copyWith(getState: RequestState.error, error: failure.toString())),
      (visit) => emit(state.copyWith(getState: RequestState.loaded, visit: visit, clearError: true)),
    );
  }

  Future<void> _options(LoadVisitEditOptionsEvent event, Emitter<VisitDetailState> emit) async {
    emit(state.copyWith(optionsState: RequestState.loading));
    final results = await Future.wait<dynamic>([
      getClientsUc.call(NoParameters()),
      getServicesUc.call(NoParameters()),
      getTechniciansUc.call(NoParameters()),
    ]);
    var failed = false;
    List<VisitClientModel> clients = [];
    List<ServiceModel> services = [];
    List<TechnicianModel> technicians = [];
    results[0].fold((dynamic _) => failed = true,
        (dynamic data) => clients = (data as List).map((e) => e.convertToVisitClient() as VisitClientModel).toList());
    results[1].fold((dynamic _) => failed = true,
        (dynamic data) => services = List<ServiceModel>.from(data as List));
    results[2].fold((dynamic _) => failed = true,
        (dynamic data) => technicians = List<TechnicianModel>.from(data as List));
    emit(state.copyWith(optionsState: failed ? RequestState.error : RequestState.loaded,
      clients: clients, services: services, technicians: technicians));
  }

  Future<void> _run(Emitter<VisitDetailState> emit, Future<dynamic> Function() action) async {
    if (state.actionState == RequestState.loading) return;
    emit(state.copyWith(actionState: RequestState.loading, clearError: true));
    final result = await action();
    result.fold(
      (dynamic failure) => emit(state.copyWith(actionState: RequestState.error, error: failure.toString())),
      (dynamic visit) => emit(state.copyWith(actionState: RequestState.loaded,
          visit: visit as VisitDetailModel, actionSuccessCount: state.actionSuccessCount + 1,
          clearError: true)),
    );
  }
}
