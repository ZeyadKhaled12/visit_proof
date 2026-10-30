import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/add_visit/domain/usecases/add_visit_uc.dart';
import 'package:visit_proof/features/clients/domain/usecases/get_clients_uc.dart';
import 'package:visit_proof/features/services/domain/usecases/get_services_uc.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_technicians_uc.dart';

import '../../../../core/utils/enums.dart';
import '../../../services/data/models/service_model.dart';
import '../../../technicians/data/models/technician_model.dart';
import '../../../visits/data/models/visit_detail_models/visit_client_model.dart';

part 'add_visit_event.dart';
part 'add_visit_state.dart';

class AddVisitBloc extends Bloc<AddVisitEvent, AddVisitState> {
  final GetClientsUc getClientsUc;
  final GetServicesUc getServicesUc;
  final GetTechniciansUc getTechniciansUc;
  final AddVisitUc addVisitUc;
  AddVisitBloc(this.getClientsUc, this.getServicesUc, this.getTechniciansUc,
      this.addVisitUc)
      : super(AddVisitState()) {
    on<GetVisitClientsEvent>(_getVisitClients);
    on<GetVisitServicesEvent>(_getVisitServices);
    on<GetVisitTechnicainsEvent>(_getVisitTechnicains);
    on<AddNewVisitEvent>(_addNewVisit);
  }

  FutureOr<void> _getVisitClients(
      GetVisitClientsEvent event, Emitter<AddVisitState> emit) async {
    emit(state.copyWith(getClientsRequestState: RequestState.loading));
    final result = await getClientsUc.call(event.noParameters);
    result.fold(
        (l) => emit(state.copyWith(getClientsRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getClientsRequestState: RequestState.loaded,
            clients: r.map((e) => e.convertToVisitClient()).toList())));
  }

  FutureOr<void> _getVisitServices(
      GetVisitServicesEvent event, Emitter<AddVisitState> emit) async {
    emit(state.copyWith(getServicesRequestState: RequestState.loading));
    final result = await getServicesUc.call(event.noParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(getServicesRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getServicesRequestState: RequestState.loaded, services: r)));
  }

  FutureOr<void> _getVisitTechnicains(
      GetVisitTechnicainsEvent event, Emitter<AddVisitState> emit) async {
    emit(state.copyWith(getTechnicanRequestState: RequestState.loading));
    final result = await getTechniciansUc.call(event.noParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(getTechnicanRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getTechnicanRequestState: RequestState.loaded, technicans: r)));
  }

  FutureOr<void> _addNewVisit(
      AddNewVisitEvent event, Emitter<AddVisitState> emit) async {
    emit(state.copyWith(addVisitRequestState: RequestState.loading));
    final result = await addVisitUc.call(event.addVisitParameters);
    result.fold(
        (l) => emit(state.copyWith(addVisitRequestState: RequestState.error)),
        (r) => emit(state.copyWith(addVisitRequestState: RequestState.loaded)));
  }
}
