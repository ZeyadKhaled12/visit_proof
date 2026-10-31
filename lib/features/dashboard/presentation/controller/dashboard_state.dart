part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  final DashboardSnapshotModel snapshot;

  /// Selected window; null means the default, the last 7 days.
  final DashboardPeriod? selectedPeriod;
  final RequestState getDashboardRequestState;

  const DashboardState({
    this.snapshot = const DashboardSnapshotModel(),
    this.selectedPeriod,
    this.getDashboardRequestState = RequestState.loaded,
  });

  DashboardPeriod get period =>
      selectedPeriod ??
      DashboardPeriod.of(DashboardRange.last7Days, now: DateTime.now());

  /// True once data has loaded at least once.
  bool get hasData => snapshot.loadedAt != null;

  DashboardState copyWith({
    DashboardSnapshotModel? snapshot,
    DashboardPeriod? period,
    RequestState? getDashboardRequestState,
  }) {
    return DashboardState(
      snapshot: snapshot ?? this.snapshot,
      selectedPeriod: period ?? selectedPeriod,
      getDashboardRequestState:
          getDashboardRequestState ?? this.getDashboardRequestState,
    );
  }

  @override
  List<Object?> get props => [snapshot, selectedPeriod, getDashboardRequestState];
}
