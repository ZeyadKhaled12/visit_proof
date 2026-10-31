part of 'dispatch_bloc.dart';

class DispatchState extends Equatable {
  /// Day shown on the board; null means today.
  final DateTime? selectedDate;
  final List<VisitDetailModel> visits;
  final List<TechnicianModel> technicians;
  final DispatchSettingsModel settings;
  final List<TechnicianDayOffModel> daysOff;
  final int bulkSucceeded;
  final List<String> bulkFailures;
  final RequestState getBoardRequestState;
  final RequestState assignRequestState;
  final RequestState unassignRequestState;
  final RequestState rescheduleRequestState;
  final RequestState changeStatusRequestState;
  final RequestState changePriorityRequestState;
  final RequestState bulkAssignRequestState;
  final RequestState saveSettingsRequestState;
  final RequestState dayOffRequestState;

  const DispatchState({
    this.selectedDate,
    this.visits = const [],
    this.technicians = const [],
    this.settings = DispatchSettingsModel.defaults,
    this.daysOff = const [],
    this.bulkSucceeded = 0,
    this.bulkFailures = const [],
    this.getBoardRequestState = RequestState.loaded,
    this.assignRequestState = RequestState.loaded,
    this.unassignRequestState = RequestState.loaded,
    this.rescheduleRequestState = RequestState.loaded,
    this.changeStatusRequestState = RequestState.loaded,
    this.changePriorityRequestState = RequestState.loaded,
    this.bulkAssignRequestState = RequestState.loaded,
    this.saveSettingsRequestState = RequestState.loaded,
    this.dayOffRequestState = RequestState.loaded,
  });

  DateTime get day {
    final value = selectedDate ?? DateTime.now();
    return DateTime(value.year, value.month, value.day);
  }

  /// The latest copy of a visit, so open sheets always show fresh data.
  VisitDetailModel? visitById(String? id) =>
      id == null ? null : visits.where((v) => v.id == id).firstOrNull;

  DispatchState copyWith({
    DateTime? selectedDate,
    List<VisitDetailModel>? visits,
    List<TechnicianModel>? technicians,
    DispatchSettingsModel? settings,
    List<TechnicianDayOffModel>? daysOff,
    int? bulkSucceeded,
    List<String>? bulkFailures,
    RequestState? getBoardRequestState,
    RequestState? assignRequestState,
    RequestState? unassignRequestState,
    RequestState? rescheduleRequestState,
    RequestState? changeStatusRequestState,
    RequestState? changePriorityRequestState,
    RequestState? bulkAssignRequestState,
    RequestState? saveSettingsRequestState,
    RequestState? dayOffRequestState,
  }) {
    return DispatchState(
      selectedDate: selectedDate ?? this.selectedDate,
      visits: visits ?? this.visits,
      technicians: technicians ?? this.technicians,
      settings: settings ?? this.settings,
      daysOff: daysOff ?? this.daysOff,
      bulkSucceeded: bulkSucceeded ?? this.bulkSucceeded,
      bulkFailures: bulkFailures ?? this.bulkFailures,
      getBoardRequestState: getBoardRequestState ?? this.getBoardRequestState,
      assignRequestState: assignRequestState ?? this.assignRequestState,
      unassignRequestState: unassignRequestState ?? this.unassignRequestState,
      rescheduleRequestState:
          rescheduleRequestState ?? this.rescheduleRequestState,
      changeStatusRequestState:
          changeStatusRequestState ?? this.changeStatusRequestState,
      changePriorityRequestState:
          changePriorityRequestState ?? this.changePriorityRequestState,
      bulkAssignRequestState:
          bulkAssignRequestState ?? this.bulkAssignRequestState,
      saveSettingsRequestState:
          saveSettingsRequestState ?? this.saveSettingsRequestState,
      dayOffRequestState: dayOffRequestState ?? this.dayOffRequestState,
    );
  }

  @override
  List<Object?> get props => [
        selectedDate,
        visits,
        technicians,
        settings,
        daysOff,
        bulkSucceeded,
        bulkFailures,
        getBoardRequestState,
        assignRequestState,
        unassignRequestState,
        rescheduleRequestState,
        changeStatusRequestState,
        changePriorityRequestState,
        bulkAssignRequestState,
        saveSettingsRequestState,
        dayOffRequestState,
      ];
}
