import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/visits/domain/usecases/get_visits_uc.dart';

import '../../../../core/utils/enums.dart';
import '../../data/models/visit_detail_models/visit_detail_model.dart';

part 'visits_event.dart';
part 'visits_state.dart';

class VisitsBloc extends Bloc<VisitsEvent, VisitsState> {
  final GetVisitsUc getVisitsUc;
  VisitsBloc(this.getVisitsUc) : super(VisitsState()) {
    on<GetVisitsEvent>(_getVisits);
  }

  FutureOr<void> _getVisits(
      GetVisitsEvent event, Emitter<VisitsState> emit) async {
    emit(state.copyWith(getVisitsRequestState: RequestState.loading));
    final result = await getVisitsUc.call(event.noParameters);
    result.fold(
        (l) => emit(state.copyWith(getVisitsRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getVisitsRequestState: RequestState.loaded, visits: r)));
  }
}
