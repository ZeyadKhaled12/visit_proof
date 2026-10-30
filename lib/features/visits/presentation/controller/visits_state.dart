part of 'visits_bloc.dart';

class VisitsState extends Equatable {
  final List<VisitDetailModel> visits;
  final RequestState getVisitsRequestState;

  const VisitsState(
      {this.visits = const [],
      this.getVisitsRequestState = RequestState.loaded});

  VisitsState copyWith(
      {List<VisitDetailModel>? visits, RequestState? getVisitsRequestState}) {
    return VisitsState(
      visits: visits ?? this.visits,
      getVisitsRequestState:
          getVisitsRequestState ?? this.getVisitsRequestState,
    );
  }

  @override
  List<Object> get props => [visits, getVisitsRequestState];
}
