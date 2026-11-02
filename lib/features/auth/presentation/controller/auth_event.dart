part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginTechnicianEvent extends AuthEvent {
  final LoginTechnicianParameters loginTechnicianParameters;
  const LoginTechnicianEvent({required this.loginTechnicianParameters});
  @override
  List<Object> get props => [loginTechnicianParameters];
}

class EnterAsAdminEvent extends AuthEvent {
  final NoParameters noParameters;
  const EnterAsAdminEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}

class LogoutEvent extends AuthEvent {
  final NoParameters noParameters;
  const LogoutEvent({required this.noParameters});
  @override
  List<Object> get props => [noParameters];
}
