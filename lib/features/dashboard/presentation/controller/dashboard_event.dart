part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class GetDashboardEvent extends DashboardEvent {
  final NoParameters noParameters;
  const GetDashboardEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}

class ChangeDashboardPeriodEvent extends DashboardEvent {
  final DashboardPeriod period;
  const ChangeDashboardPeriodEvent({required this.period});
  @override
  List<Object> get props => [period];
}
