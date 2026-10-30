import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';
import 'package:visit_proof/features/services/domain/usecases/get_categories_uc.dart';
import 'package:visit_proof/features/technicians/data/models/technician_detail_model.dart';
import 'package:visit_proof/features/technicians/data/models/technician_model.dart';
import 'package:visit_proof/features/technicians/domain/usecases/get_technicians_uc.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/usecases/add_tech_uc.dart';
import '../../domain/usecases/get_tech_detail_uc.dart';
import '../../domain/usecases/remove_technician_uc.dart';

part 'tech_event.dart';
part 'tech_state.dart';

class TechBloc extends Bloc<TechEvent, TechState> {
  final GetTechniciansUc getTechniciansUc;
  final AddTechUc addTechUc;
  final GetTechDetailUc getTechDetailUc;
  final RemoveTechnicianUc removeTechnicianUc;
  final GetCategoriesUc getCategoriesUc;
  TechBloc(this.getTechniciansUc, this.addTechUc, this.getTechDetailUc,
      this.removeTechnicianUc, this.getCategoriesUc)
      : super(TechState()) {
    on<GetTechniciansEvent>(_getTechnicians);
    on<AddTechEvent>(_addTech);
    on<GetTechDetailEvent>(_getTechDetail);
    on<RemoveTechEvent>(_removeTech);
    on<GetTCategoriesEvent>(_getTCategories);
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

  FutureOr<void> _addTech(AddTechEvent event, Emitter<TechState> emit) async {
    emit(state.copyWith(addTechnicianRequestState: RequestState.loading));
    final result = await addTechUc.call(event.addTechParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(addTechnicianRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            addTechnicianRequestState: RequestState.loaded,
            technicianDetailModel: r)));
  }

  FutureOr<void> _getTechDetail(
      GetTechDetailEvent event, Emitter<TechState> emit) async {
    emit(state.copyWith(getTechnicianDetailRequestState: RequestState.loading));
    final result = await getTechDetailUc.call(event.getTechDetailParameters);
    result.fold(
        (l) => emit(state.copyWith(
            getTechnicianDetailRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getTechnicianDetailRequestState: RequestState.loaded,
            technicianDetailModel: r)));
  }

  FutureOr<void> _removeTech(
      RemoveTechEvent event, Emitter<TechState> emit) async {
    emit(state.copyWith(removeTechnicianRequestState: RequestState.loading));
    final result =
        await removeTechnicianUc.call(event.removeTechnicianParameters);
    result.fold(
        (l) => emit(
            state.copyWith(removeTechnicianRequestState: RequestState.error)),
        (r) => emit(
            state.copyWith(removeTechnicianRequestState: RequestState.loaded)));
  }

  FutureOr<void> _getTCategories(
      GetTCategoriesEvent event, Emitter<TechState> emit) async {
    emit(state.copyWith(getCategoriesRequestState: RequestState.loading));
    final result = await getCategoriesUc.call(event.noParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(getCategoriesRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getCategoriesRequestState: RequestState.loaded, categories: r)));
  }
}
