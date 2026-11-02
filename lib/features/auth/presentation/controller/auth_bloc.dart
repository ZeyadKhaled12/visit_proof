import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/base_use_case.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/usecases/enter_as_admin_uc.dart';
import '../../domain/usecases/login_technician_uc.dart';
import '../../domain/usecases/logout_uc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginTechnicianUc loginTechnicianUc;
  final EnterAsAdminUc enterAsAdminUc;
  final LogoutUc logoutUc;

  AuthBloc(this.loginTechnicianUc, this.enterAsAdminUc, this.logoutUc)
      : super(const AuthState()) {
    on<LoginTechnicianEvent>(_loginTechnician);
    on<EnterAsAdminEvent>(_enterAsAdmin);
    on<LogoutEvent>(_logout);
  }

  FutureOr<void> _loginTechnician(
      LoginTechnicianEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loginRequestState: RequestState.loading));
    final result =
        await loginTechnicianUc.call(event.loginTechnicianParameters);
    result.fold(
        (l) => emit(state.copyWith(loginRequestState: RequestState.error)),
        (r) => emit(state.copyWith(loginRequestState: RequestState.loaded)));
  }

  FutureOr<void> _enterAsAdmin(
      EnterAsAdminEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(enterAsAdminRequestState: RequestState.loading));
    final result = await enterAsAdminUc.call(event.noParameters);
    result.fold(
        (l) =>
            emit(state.copyWith(enterAsAdminRequestState: RequestState.error)),
        (r) => emit(
            state.copyWith(enterAsAdminRequestState: RequestState.loaded)));
  }

  FutureOr<void> _logout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(logoutRequestState: RequestState.loading));
    final result = await logoutUc.call(event.noParameters);
    result.fold(
        (l) => emit(state.copyWith(logoutRequestState: RequestState.error)),
        (r) => emit(state.copyWith(logoutRequestState: RequestState.loaded)));
  }
}
