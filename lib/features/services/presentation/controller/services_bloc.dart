import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visit_proof/core/usecase/base_use_case.dart';
import 'package:visit_proof/core/utils/general_models/g_model_catg.dart';
import 'package:visit_proof/features/services/data/models/service_model.dart';
import 'package:visit_proof/features/services/domain/usecases/get_services_uc.dart';

import '../../../../core/utils/enums.dart';
import '../../domain/usecases/add_service_uc.dart';
import '../../domain/usecases/get_categories_uc.dart';
import '../../domain/usecases/remove_service_uc.dart';

part 'services_event.dart';
part 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final GetServicesUc getServicesUc;
  final GetCategoriesUc getCategoriesUc;
  final AddServiceUc addServiceUc;
  final RemoveServiceUc removeServiceUc;
  ServicesBloc(this.getServicesUc, this.addServiceUc, this.getCategoriesUc,
      this.removeServiceUc)
      : super(ServicesState()) {
    on<GetServicesEvent>(_getServices);
    on<GetCategoriesEvent>(_getCategories);
    on<AddServiceEvent>(_addService);
    on<RemoveServiceEvent>(_removeService);
  }

  FutureOr<void> _getServices(
      GetServicesEvent event, Emitter<ServicesState> emit) async {
    emit(state.copyWith(getServicesRequestState: RequestState.loading));
    final result = await getServicesUc.call(event.noParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(getServicesRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getServicesRequestState: RequestState.loaded, services: r)));
  }

  FutureOr<void> _getCategories(
      GetCategoriesEvent event, Emitter<ServicesState> emit) async {
    emit(state.copyWith(getCategoriesRequestState: RequestState.loading));
    final result = await getCategoriesUc.call(event.noParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(getCategoriesRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getCategoriesRequestState: RequestState.loaded, categories: r)));
  }

  FutureOr<void> _addService(
      AddServiceEvent event, Emitter<ServicesState> emit) async {
    emit(state.copyWith(addServiceRequestState: RequestState.loading));
    final result = await addServiceUc.call(event.addServiceParameters);
    result.fold(
        (l) => emit(state.copyWith(addServiceRequestState: RequestState.error)),
        (r) =>
            emit(state.copyWith(addServiceRequestState: RequestState.loaded)));
  }

  FutureOr<void> _removeService(
      RemoveServiceEvent event, Emitter<ServicesState> emit) async {
    emit(state.copyWith(getServicesRequestState: RequestState.loading));
    final result = await removeServiceUc.call(event.removeServiceParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(getServicesRequestState: RequestState.error)),
        (r) => emit(state.copyWith(
            getServicesRequestState: RequestState.loaded, services: r)));
  }
}
