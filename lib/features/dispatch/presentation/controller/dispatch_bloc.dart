import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/error/failure.dart';
import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums.dart';
import '../../../technicians/data/models/technician_model.dart';
import '../../../technicians/domain/usecases/get_technicians_uc.dart';
import '../../../visit_detail/domain/usecases/assign_technician_uc.dart';
import '../../../visit_detail/domain/usecases/change_visit_status_uc.dart';
import '../../../visit_detail/domain/usecases/reschedule_visit_uc.dart';
import '../../../visit_detail/domain/usecases/unassign_technician_uc.dart';
import '../../../visit_detail/domain/usecases/update_visit_info_uc.dart';
import '../../../visits/data/models/visit_detail_models/visit_detail_model.dart';
import '../../../visits/domain/usecases/get_visits_uc.dart';
import '../../data/models/dispatch_settings_model.dart';
import '../../data/models/technician_day_off_model.dart';
import '../../domain/usecases/get_dispatch_settings_uc.dart';
import '../../domain/usecases/get_technician_days_off_uc.dart';
import '../../domain/usecases/save_dispatch_settings_uc.dart';
import '../../domain/usecases/set_technician_day_off_uc.dart';

part 'dispatch_event.dart';
part 'dispatch_state.dart';

typedef _StateWith = DispatchState Function(RequestState requestState);

class DispatchBloc extends Bloc<DispatchEvent, DispatchState> {
  final GetVisitsUc getVisitsUc;
  final GetTechniciansUc getTechniciansUc;
  final GetDispatchSettingsUc getDispatchSettingsUc;
  final SaveDispatchSettingsUc saveDispatchSettingsUc;
  final GetTechnicianDaysOffUc getTechnicianDaysOffUc;
  final SetTechnicianDayOffUc setTechnicianDayOffUc;
  final AssignTechnicianUc assignTechnicianUc;
  final UnassignTechnicianUc unassignTechnicianUc;
  final RescheduleVisitUc rescheduleVisitUc;
  final ChangeVisitStatusUc changeVisitStatusUc;
  final UpdateVisitInfoUc updateVisitInfoUc;

  DispatchBloc(
      this.getVisitsUc,
      this.getTechniciansUc,
      this.getDispatchSettingsUc,
      this.saveDispatchSettingsUc,
      this.getTechnicianDaysOffUc,
      this.setTechnicianDayOffUc,
      this.assignTechnicianUc,
      this.unassignTechnicianUc,
      this.rescheduleVisitUc,
      this.changeVisitStatusUc,
      this.updateVisitInfoUc)
      : super(const DispatchState()) {
    on<GetDispatchBoardEvent>(_getDispatchBoard);
    on<ChangeDispatchDateEvent>(_changeDispatchDate);
    on<DispatchAssignEvent>(_assign);
    on<DispatchBulkAssignEvent>(_bulkAssign);
    on<DispatchUnassignEvent>(_unassign);
    on<DispatchRescheduleEvent>(_reschedule);
    on<DispatchChangeStatusEvent>(_changeStatus);
    on<DispatchChangePriorityEvent>(_changePriority);
    on<SaveDispatchSettingsEvent>(_saveSettings);
    on<SetTechnicianDayOffEvent>(_setTechnicianDayOff);
  }

  // ==========================================================
  // LOAD
  // ==========================================================

  FutureOr<void> _getDispatchBoard(
      GetDispatchBoardEvent event, Emitter<DispatchState> emit) async {
    emit(state.copyWith(getBoardRequestState: RequestState.loading));

    final visits = await getVisitsUc.call(event.noParameters);
    final technicians = await getTechniciansUc.call(event.noParameters);
    final settings = await getDispatchSettingsUc.call(event.noParameters);
    final daysOff = await getTechnicianDaysOffUc.call(event.noParameters);

    if (visits.isLeft ||
        technicians.isLeft ||
        settings.isLeft ||
        daysOff.isLeft) {
      emit(state.copyWith(getBoardRequestState: RequestState.error));
      return;
    }

    emit(state.copyWith(
        getBoardRequestState: RequestState.loaded,
        visits: visits.right,
        technicians: technicians.right,
        settings: settings.right,
        daysOff: daysOff.right));
  }

  FutureOr<void> _changeDispatchDate(
      ChangeDispatchDateEvent event, Emitter<DispatchState> emit) {
    emit(state.copyWith(selectedDate: event.date));
  }

  /// Reloads visits and technician counts after a change, without the
  /// full-screen loader.
  Future<void> _refreshBoard(Emitter<DispatchState> emit) async {
    final visits = await getVisitsUc.call(const NoParameters());
    final technicians = await getTechniciansUc.call(const NoParameters());
    emit(state.copyWith(
        visits: visits.isRight ? visits.right : null,
        technicians: technicians.isRight ? technicians.right : null));
  }

  // ==========================================================
  // VISIT ACTIONS (rules live in the visit_detail feature)
  // ==========================================================

  FutureOr<void> _assign(
          DispatchAssignEvent event, Emitter<DispatchState> emit) =>
      _updateVisit(emit,
          call: () => assignTechnicianUc.call(event.assignTechnicianParameters),
          stateWith: (s) => state.copyWith(assignRequestState: s));

  FutureOr<void> _unassign(
          DispatchUnassignEvent event, Emitter<DispatchState> emit) =>
      _updateVisit(emit,
          call: () =>
              unassignTechnicianUc.call(event.unassignTechnicianParameters),
          stateWith: (s) => state.copyWith(unassignRequestState: s));

  FutureOr<void> _reschedule(
          DispatchRescheduleEvent event, Emitter<DispatchState> emit) =>
      _updateVisit(emit,
          call: () => rescheduleVisitUc.call(event.rescheduleVisitParameters),
          stateWith: (s) => state.copyWith(rescheduleRequestState: s));

  FutureOr<void> _changeStatus(
          DispatchChangeStatusEvent event, Emitter<DispatchState> emit) =>
      _updateVisit(emit,
          call: () => changeVisitStatusUc.call(event.changeVisitStatusParameters),
          stateWith: (s) => state.copyWith(changeStatusRequestState: s));

  FutureOr<void> _changePriority(
          DispatchChangePriorityEvent event, Emitter<DispatchState> emit) =>
      _updateVisit(emit,
          call: () => updateVisitInfoUc.call(event.updateVisitInfoParameters),
          stateWith: (s) => state.copyWith(changePriorityRequestState: s));

  /// Assigns several visits one by one and reports what succeeded.
  FutureOr<void> _bulkAssign(
      DispatchBulkAssignEvent event, Emitter<DispatchState> emit) async {
    emit(state.copyWith(
        bulkAssignRequestState: RequestState.loading,
        bulkSucceeded: 0,
        bulkFailures: const []));

    var succeeded = 0;
    final failures = <String>[];
    for (final parameters in event.assignments) {
      final result = await assignTechnicianUc.call(parameters);
      result.fold(
          (l) => failures.add(l.errorMessageModel.statusMessage),
          (r) => succeeded++);
    }

    await _refreshBoard(emit);
    emit(state.copyWith(
        bulkAssignRequestState: RequestState.loaded,
        bulkSucceeded: succeeded,
        bulkFailures: failures));
  }

  Future<void> _updateVisit(
    Emitter<DispatchState> emit, {
    required Future<Either<Failure, VisitDetailModel>> Function() call,
    required _StateWith stateWith,
  }) async {
    emit(stateWith(RequestState.loading));
    final result = await call();
    if (result.isLeft) {
      emit(stateWith(RequestState.error));
      return;
    }
    await _refreshBoard(emit);
    emit(stateWith(RequestState.loaded));
  }

  // ==========================================================
  // DISPATCH SETTINGS & AVAILABILITY
  // ==========================================================

  FutureOr<void> _saveSettings(
      SaveDispatchSettingsEvent event, Emitter<DispatchState> emit) async {
    emit(state.copyWith(saveSettingsRequestState: RequestState.loading));
    final result =
        await saveDispatchSettingsUc.call(event.saveDispatchSettingsParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(saveSettingsRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            saveSettingsRequestState: RequestState.loaded, settings: r)));
  }

  FutureOr<void> _setTechnicianDayOff(
      SetTechnicianDayOffEvent event, Emitter<DispatchState> emit) async {
    emit(state.copyWith(dayOffRequestState: RequestState.loading));
    final result =
        await setTechnicianDayOffUc.call(event.setTechnicianDayOffParameters);
    result.fold(
        (l) => emit(state.copyWith(dayOffRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            dayOffRequestState: RequestState.loaded, daysOff: r)));
  }
}
