import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/features/technicians/data/models/technician_detail_model.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_technicians_uc.dart';

import '../../../../core/utils/enums.dart';

part 'tech_event.dart';
part 'tech_state.dart';

class TechBloc extends Bloc<TechEvent, TechState> {
  final GetTechniciansUc getTechniciansUc;
  TechBloc(this.getTechniciansUc) : super(TechState()) {
    on<GetTechniciansEvent>(_getTechnicians);
  }

  FutureOr<void> _getTechnicians(
      GetTechniciansEvent event, Emitter<TechState> emit) async {
    emit(state.copyWith(getTechniciansRequestState: RequestState.loading));
    final result = await getTechniciansUc.call(event.noParameters);
    result.fold(
        (l) => emit(
            state.copyWith(getTechniciansRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getTechniciansRequestState: RequestState.loaded, technicians: r)));
  }
}
