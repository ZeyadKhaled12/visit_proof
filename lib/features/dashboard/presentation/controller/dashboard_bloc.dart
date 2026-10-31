import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums.dart';
import '../../data/models/dashboard_snapshot_model.dart';
import '../../domain/rules/dashboard_period.dart';
import '../../domain/usecases/get_dashboard_snapshot_uc.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSnapshotUc getDashboardSnapshotUc;

  DashboardBloc(this.getDashboardSnapshotUc) : super(const DashboardState()) {
    on<GetDashboardEvent>(_getDashboard);
    on<ChangeDashboardPeriodEvent>(_changePeriod);
  }

  FutureOr<void> _getDashboard(
      GetDashboardEvent event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(getDashboardRequestState: RequestState.loading));
    final result = await getDashboardSnapshotUc.call(event.noParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(getDashboardRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getDashboardRequestState: RequestState.loaded, snapshot: r)));
  }

  /// Metrics are computed from the loaded snapshot, so changing the period
  /// is instant and needs no new read.
  FutureOr<void> _changePeriod(
      ChangeDashboardPeriodEvent event, Emitter<DashboardState> emit) {
    emit(state.copyWith(period: event.period));
  }
}
