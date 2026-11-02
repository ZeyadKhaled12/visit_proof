part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final RequestState loginRequestState;
  final RequestState enterAsAdminRequestState;
  final RequestState logoutRequestState;

  const AuthState({
    this.loginRequestState = RequestState.loaded,
    this.enterAsAdminRequestState = RequestState.loaded,
    this.logoutRequestState = RequestState.loaded,
  });

  AuthState copyWith({
    RequestState? loginRequestState,
    RequestState? enterAsAdminRequestState,
    RequestState? logoutRequestState,
  }) {
    return AuthState(
      loginRequestState: loginRequestState ?? this.loginRequestState,
      enterAsAdminRequestState:
          enterAsAdminRequestState ?? this.enterAsAdminRequestState,
      logoutRequestState: logoutRequestState ?? this.logoutRequestState,
    );
  }

  @override
  List<Object> get props =>
      [loginRequestState, enterAsAdminRequestState, logoutRequestState];
}
